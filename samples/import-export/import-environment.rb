###################################  TO RUN  ###################################
#
# This driver file assumes the Kinetic SDK is located in the relative directory:
#   - vendor/kinetic-sdk-rb
#
#
# 1. Ensure ruby (or jruby) is installed
# 2. Create a yaml file in the 'config' directory (will be omitted from git)
# 3. Ensure the 'exports' directory exists
# 4. Clone the platform-template Github repository into the 'exports' directory,
#    and name it 'platform_template' (e.g. exports/platform_template)
# 5. ruby import-environment.rb \
#      -e template \
#      -s <new-space-slug> \
#      -n <new-space-name> \
#      -c <config-file-name.yaml> \
#      -o <overwrite-if-exists> \
#      -t <type of import>
################################################################################

require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'time'
require 'yaml'


class ImportOptions

  IMPORT_TYPES = %w[ce task ce/task all]

  #
  # Return a structure describing the options.
  #
  def self.parse(args)

    args << '-h' if args.empty?

    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.export_space_slug = nil
    options.space_slug = nil
    options.space_name = nil
    options.import_overwrite = false
    options.import_type = "create"

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: import-core.rb [options]"

      opts.separator ""

      opts.on("-e EXPORT_SPACE_SLUG",
              "The slug of the exported Space",
              "  This is used to retrieve the data files") do |slug|
        options.export_space_slug = slug
      end

      opts.on("-n SPACE_NAME",
              "The name of the new Space to import (wrap in quotes)") do |name|
        options.space_name = name
      end

      opts.on("-s SPACE_SLUG",
              "The slug of the new Space to import") do |slug|
        options.space_slug = slug
      end

      opts.on("-c CONFIG_FILE",
              "The config file to use for the export (must be in ./config directory)") do |cfg_file|
        options.cfg = cfg_file
      end

      opts.on("-o IMPORT_OVERWRITE", %w[true false],
              "Whether to overwrite the data if it already exists: (true|false)",
              "  Existing data will be deleted and recreated",
              "  Existing data will remain intact, import will skip") do |overwrite|
        options.import_overwrite = overwrite.to_s.downcase == "true"
      end

      opts.on("-t IMPORT_TYPE", IMPORT_TYPES,
                    "The type of import to do: (ce|task|ce/task|all)",
                    "  CE Will Only Import CE Data",
                    "  Task Will Only Import Task Data",
                    "  CE/TASK will import CE and Task Data and configure both",
                    "  All will import CE/Task & configure Filehub and Bridgehub as well") do |type|
        if type.to_s.downcase == "ce"
          options.importCE = true
          options.importTask = false
          options.configureFH = false
          options.configureBH = false
        elsif type.to_s.downcase == "task"
          options.importCE = false
          options.importTask = true
          options.configureFH = false
          options.configureBH = false
        elsif  type.to_s.downcase == "ce/task"
          options.importCE = true
          options.importTask = true
          options.configureFH = false
          options.configureBH = false
        else
          options.importCE = true
          options.importTask = true
          options.configureFH = true
          options.configureBH = true
        end
          
      end

      opts.separator ""
      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

    end

    opt_parser.parse!(args)
    options
  end
end


# Determine the Present Working Directory
pwd = File.expand_path(File.dirname(__FILE__))

if Dir.exist?('vendor')
  # Require the Kinetic SDK from the vendor directory
  require File.join(pwd, 'vendor', 'kinetic-sdk-rb', 'kinetic-sdk')
elsif File.exist?(File.join(pwd, '../..', 'kinetic-sdk.rb'))
  # Assume this script is running from the samples directory
  require File.join(pwd, '../..', 'kinetic-sdk')
else
  puts "Cannot find the kinetic-sdk"
  exit
end

require 'parallel'

# Parse options from command line arguments
options = ImportOptions.parse(ARGV)

# Get Space Name / Slug and Export Space Slug
space_slug = options.space_slug
space_name = options.space_name
export_space_slug = options.export_space_slug

# Get the environment file
config_file = "#{pwd}/config/#{options.cfg}"
env = nil
begin
  config = open(config_file)
  env = YAML.load(config.read)
rescue
  puts "The configuration file #{options.cfg} does not exist."
  exit
end

# Build and move to the Export Directory for this space
space_dir = "#{pwd}/exports/#{export_space_slug}"
FileUtils.mkdir_p(space_dir, :mode => 0700) unless Dir.exist?(space_dir)
Dir.chdir(space_dir)

# Platform
platform_task_source_name = env.has_key?("platform") ? env["platform"]["task_source_name"] : nil

# SDK Logging
log_level = ENV['SDK_LOG_LEVEL'] || env['sdk_log_level'] || "info"

# Request CE
ce_server = env["ce"]["server"]
ce_task_source_name = env["ce"]["task_source_name"]
ce_integration_username = env["ce"]["space_integration_credentials"]["username"]
ce_integration_displayname = env["ce"]["space_integration_credentials"]["display_name"]
ce_integration_password = KineticSdk::Utils::Random.simple
# Get the Request CE configurator user credentials from an external file
ce_credentials = {
  "username" => env["ce"]["system_credentials"]["username"],
  "password" => env["ce"]["system_credentials"]["password"]
}
# Get the Request CE space user credentials from an external file
ce_credentials_space_admin = {
  "username" => env["ce"]["space_admin_credentials"]["username"],
  "password" => env["ce"]["space_admin_credentials"]["password"]
}

# Task
task_server = env["task"]["server"]
task_oauth_server = (env["task"].has_key?("oauth") && env["task"]["oauth"]["endpoint_server"]) ?
  env["task"]["oauth"]["endpoint_server"] :
  ce_server
task_oauth_redirect_server = (env["task"].has_key?("oauth") && env["task"]["oauth"]["redirect_endpoint_server"]) ?
  env["task"]["oauth"]["redirect_endpoint_server"] :
  task_server
task_access_key = {
  "description" => "Request CE",
  "identifier" => "request-ce",
  "secret" => KineticSdk::Utils::Random.simple
}
oauth_secret_task = KineticSdk::Utils::Random.simple
signature_policy_rule = {
  "name" => "Valid Signature",
  "type" => "API Access",
  "rule" => "@auth.validateSignature('#{task_access_key['identifier']}')",
  "message" => "The request signature is invalid",
  "consolePolicyRules": []
}

# BridgeHub
bridgehub_server = env['bridgehub']['server']
bridge_slug = "ce-#{space_slug}"

# FileHub
filehub_server = env['filehub']['server']
filestore_slug = "ce-#{space_slug}"
filestore_data_location = (env['ce'].has_key?('filestore') ?
    env['ce']['filestore']['directory'] : "") || "/home/filesDirectory"


#--------------------------------------------------------------------------
# Request CE
#--------------------------------------------------------------------------
if options.importCE

  requestce_sdk_system = KineticSdk::RequestCe.new({
    app_server_url: ce_server,
    username: ce_credentials["username"],
    password: ce_credentials["password"],
    options: { log_level: log_level }
  })

  # Check if the space exists
  space_exists = requestce_sdk_system.space_exists?(space_slug)
  import = false

  if !space_exists
    import = true
  elsif space_exists && options.import_overwrite
    # Delete the space
    requestce_sdk_system.delete_space(space_slug)
    import = true
  end

  if import

    # Locate Space Import Directory
    request_ce_dir = "#{space_dir}/ce"

    # Load the space
    space = JSON.parse(File.read("#{request_ce_dir}/space.json"))

    # Create the space
    puts "Creating the \"#{space_slug}\" space"
    requestce_sdk_system.add_space(space_name, space_slug)

    # Create a Space User that will be used with integrations (eg: Kinetic Task)
    puts "Adding the \"#{ce_integration_username}\" user to the \"#{space_slug}\" Request CE space."
    requestce_sdk_system.add_user({
      "space_slug" => space_slug,
      "username" => ce_integration_username,
      "password" => ce_integration_password,
      "displayName" => ce_integration_displayname,
      "enabled" => true,
      "spaceAdmin" => true
    })

    # Create a Space Admin user with a known password
    puts "Adding the \"#{ce_credentials_space_admin["username"]}\" user to the \"#{space_slug}\" Request CE space."
    requestce_sdk_system.add_user({
      "space_slug" => space_slug,
      "username" => ce_credentials_space_admin["username"],
      "password" => ce_credentials_space_admin["password"],
      "displayName" => "Space Administrator",
      "enabled" => true,
      "spaceAdmin" => true
    })

    # Update the bundle path
    requestce_sdk_system.update_space_in_system(space_slug, {
      "sharedBundleBase" => space.delete("sharedBundleBase"),
      "bundlePath" => space.delete("bundlePath")
    })

    # Log into the Space with the Space Admin user
    requestce_sdk_space = KineticSdk::RequestCe.new({
      app_server_url: ce_server,
      space_slug: space_slug,
      username: ce_credentials_space_admin["username"],
      password: ce_credentials_space_admin["password"],
      options: { log_level: log_level }
    })

    # update space name and slug from the properties that were passed in
    space['name'] = space_name
    space['slug'] = space_slug
    # update filestore settings
    space['filestore'] = {
      'slug' => filestore_slug,
      'filehubUrl' => filehub_server
    }
    # add space attribute definitions
    space['spaceAttributeDefinitions'] = 
      JSON.parse(File.read("#{request_ce_dir}/spaceAttributeDefinitions.json"))
    # add team attribute definitions
    space['teamAttributeDefinitions'] =
      JSON.parse(File.read("#{request_ce_dir}/teamAttributeDefinitions.json"))
    # add user attribute definitions
    space['userAttributeDefinitions'] = 
      JSON.parse(File.read("#{request_ce_dir}/userAttributeDefinitions.json"))
    # add user profile attribute definitions
    space['userProfileAttributeDefinitions'] = 
      JSON.parse(File.read("#{request_ce_dir}/userProfileAttributeDefinitions.json"))
    # add bridges
    space['bridges'] = Dir["#{request_ce_dir}/bridges/bridges/*"].map do |bridge_file|
      JSON.parse(File.read("#{bridge_file}")).delete_if { |k,v| k == "key" }
    end
    # update the space
    requestce_sdk_space.update_space(space)

    # add bridge models
    Dir["#{request_ce_dir}/bridges/bridgeModels/*"].map do |bridge_model_file|
      requestce_sdk_space.add_bridge_model(JSON.parse(File.read("#{bridge_model_file}")))
    end
    # add teams
    Dir["#{request_ce_dir}/teams/*"].map do |team_file|
      requestce_sdk_space.add_team(JSON.parse(File.read("#{team_file}")))
    end

    # Set Company Name Attribute on Space
    requestce_sdk_space.add_space_attribute("Company Name", "#{space_name}")

    # Delete OOTB Catalog Kapp
    requestce_sdk_space.delete_kapp("catalog");

    # Import Kapps
    Parallel.each(Dir["#{request_ce_dir}/kapp-*"]) do |dirname|

      # Import Kapp
      kapp_json = JSON.parse(File.read("#{dirname}/kapp.json"))
      kapp_slug = kapp_json['slug']
      requestce_sdk_space.add_kapp(kapp_json['name'], kapp_json['slug'], kapp_json)

      # Import Category Attribute Definitions
      obj_json = JSON.parse(File.read("#{dirname}/categoryAttributeDefinitions.json"))
      obj_json.each do |obj|
        requestce_sdk_space.add_category_attribute_definition(kapp_slug, obj['name'], obj['description'], obj['allowsMultiple'])
      end

      # Import Form Attribute Definitions
      obj_json = JSON.parse(File.read("#{dirname}/formAttributeDefinitions.json"))
      obj_json.each do |obj|
        requestce_sdk_space.add_form_attribute_definition(kapp_slug, obj['name'], obj['description'], obj['allowsMultiple'])
      end

      # Import Kapp Attribute Definitions
      obj_json = JSON.parse(File.read("#{dirname}/kappAttributeDefinitions.json"))
      obj_json.each do |obj|
        requestce_sdk_space.add_kapp_attribute_definition(kapp_slug, obj['name'], obj['description'], obj['allowsMultiple'])
      end

      # Import Security Policy Definitions
      obj_json = JSON.parse(File.read("#{dirname}/securityPolicyDefinitions.json"))
      # first delete all existing security policy definitions
      requestce_sdk_space.delete_security_policy_definitions(kapp_slug)
      # now import the form types defined in the space
      obj_json.each do |obj|
        requestce_sdk_space.add_security_policy_definition(kapp_slug, {
          "name" => obj['name'],
          "message" => obj['message'],
          "rule" => obj['rule'],
          "type" => obj['type']
        })
      end

      # Import Form Types
      obj_json = JSON.parse(File.read("#{dirname}/formTypes.json"))
      # first delete all existing form type
      requestce_sdk_space.delete_form_types_on_kapp(kapp_slug)
      # now import the form types defined in the space
      obj_json.each do |obj|
        requestce_sdk_space.add_form_type_on_kapp(kapp_slug, obj)
      end

      # Import Categories
      obj_json = JSON.parse(File.read("#{dirname}/categories.json"))
      obj_json.each do |obj|
        requestce_sdk_space.add_category_on_kapp(kapp_slug, obj)
      end

      # Import Forms
      Dir["#{dirname}/forms/*"].each do |form|
        requestce_sdk_space.add_form(kapp_slug, JSON.parse(File.read("#{form}")))
      end

      # Import Submissions
      submissions_count = 0
      Dir["#{dirname}/data/*"].each do |form|
        # Parse form slug from directory path
        form_slug = File.basename(form, '.json')
        puts "Importing submissions for: #{form_slug}"
        # Each submission is a single line on the export file
        File.readlines(form).each do |line|
          submission = JSON.parse(line)
          requestce_sdk_space.add_submission(kapp_slug, form_slug, {
            "origin" => submission['origin'],
            "parent" => submission['parent'],
            "values" => submission['values']
          })
          if (submissions_count += 1) % 25 == 0
            puts "Resetting the Request CE license submission count"
            requestce_sdk_system.reset_license_count 
          end
        end
      end

      # Import Kapp Webhooks
      obj_json = JSON.parse(File.read("#{dirname}/webhooks.json"))
      obj_json.each do |obj|
        requestce_sdk_space.add_webhook_on_kapp(kapp_slug, obj)
      end
    end

    # Import Space Webhooks
    JSON.parse(File.read("#{request_ce_dir}/webhooks.json")).each do |obj|
      requestce_sdk_space.add_space_webhook(obj)
    end

    # Update Kinetic Task webhook URLs to point to the task server
    requestce_sdk_space.find_webhooks_on_space.content['webhooks'].each do |webhook|
      url = webhook['url']
      # if the webhook contains a Kinetic Task URL
      if url.include?('/kinetic-task/app/api/v1')
        # replace the server/host portion
        apiIndex = url.index('/app/api/v1')
        url = url.sub(url.slice(0..apiIndex-1), task_server)
        # update the webhook
        requestce_sdk_space.update_webhook_on_space(webhook['name'], { 
          "url" => url,
          # add the signature access key
          "authStrategy" => {
            "type" => "Signature",
            "properties" => [
              { "name" => "Key", "value" => task_access_key['identifier'] },
              { "name" => "Secret", "value" => task_access_key['secret'] }
            ]
          }
        })
      end
    end
    requestce_sdk_space.find_kapps.content['kapps'].each do |kapp|
      requestce_sdk_space.find_webhooks_on_kapp(kapp['slug']).content['webhooks'].each do |webhook|
        url = webhook['url']
        # if the webhook contains a Kinetic Task URL
        if url.include?('/kinetic-task/app/api/v1')
          # replace the server/host portion
          apiIndex = url.index('/app/api/v1')
          url = url.sub(url.slice(0..apiIndex-1), task_server)
          # update the webhook
          requestce_sdk_space.update_webhook_on_kapp(kapp['slug'], webhook['name'], { 
            "url" => url,
            # add the signature access key
            "authStrategy" => {
              "type" => "Signature",
              "properties" => [
                { "name" => "Key", "value" => task_access_key['identifier'] },
                { "name" => "Secret", "value" => task_access_key['secret'] }
              ]
            }
          })
        end
      end
    end

    # Set the value of the "Response Server Url" Space attribute
    requestce_sdk_space.add_space_attribute("Discussion Server Url", "")
    # Set the value of the "Task Server Url" Space attribute
    requestce_sdk_space.add_space_attribute("Task Server Url", task_server)
    # Set the value of the "Web Server Url" Space attribute
    requestce_sdk_space.add_space_attribute("Web Server Url", ce_server)

    # Update Bridge on Request CE with the bridgehub slug value.
    requestce_sdk_space.update_bridge("Kinetic Core", {
      "url" => "#{bridgehub_server}/app/api/v1/bridges/#{bridge_slug}/"
    })

    # Create the oauth client for Kinetic Task
    task_oauth = {
      "name" => "Kinetic Task - #{space_slug}",
      "description" => "OAuth Provider for #{space_slug} Kinetic Task",
      "clientId" => "kinetic-task",
      "clientSecret" => oauth_secret_task,
      "redirectUri" => "#{task_oauth_redirect_server}/oauth"
    }
    if requestce_sdk_space.find_oauth_client(task_oauth['clientId']).status == 404
      requestce_sdk_space.add_oauth_client(task_oauth)
    else
      requestce_sdk_space.update_oauth_client(task_oauth['clientId'], task_oauth)
    end
  else
    puts "The #{space_slug} space already exists, skipping Request CE import."
  end
end

#--------------------------------------------------------------------------
# Task
#--------------------------------------------------------------------------
if options.importTask

  task_sdk = KineticSdk::Task.new(
    app_server_url: task_server,
    username: env["task"]["credentials"]["username"],
    password: env["task"]["credentials"]["password"],
    options: {
      export_directory: "#{space_dir}/task",
      log_level: log_level
    }
  )

  import = false

  # Check if the Request CE source exists
  ce_source_response = task_sdk.find_source(ce_task_source_name, { "include" => "policyRules" })
  if (ce_source_response.status == 404 || (ce_source_response.status == 200 && options.import_overwrite))
    import = true
  end

  if import
    puts "Create the #{ce_task_source_name} source in the Kinetic Task database"
    # Create the CE Source
    task_sdk.add_source({
      "name" => ce_task_source_name,
      "status" => "Active",
      "type" => "Kinetic Request CE",
      "properties" => {
          "Space Slug" => space_slug,
          "Web Server" => ce_server,
          "Proxy Username" => ce_integration_username,
          "Proxy Password" => ce_integration_password
      },
      "policyRules" => []
    })

    # Check if the Kinetic Task source exists
    if task_sdk.find_source("Kinetic Task").status == 404
      puts "Creating the Kinetic Task source in the Kinetic Task database."
      # Create the source
      task_sdk.add_source({
        "name" => "Kinetic Task",
        "status" => "Active",
        "type" => "Adhoc",
        "policyRules" => []
      })
    else
      puts "The Kinetic Task source already exists in the Kinetic Task database."
    end

    if task_sdk.find_source("-").status == 404
      puts "Create the global routine \"-\" source in the Kinetic Task database"
      # Create the "-" source
      task_sdk.add_source({
        "name" => "-",
        "status" => "Active",
        "type" => "Adhoc",
        "policyRules" => []
      })
    else
      puts "The global routine \"-\" source already exists in the Kinetic Task database."
    end

    # Check if the Platform source exists
    if platform_task_source_name.to_s.size > 0
      if task_sdk.find_source(platform_task_source_name).status == 404
        puts "Creating the #{platform_task_source_name} source in the Kinetic Task database."
        # Create the source
        task_sdk.add_source({
          "name" => platform_task_source_name,
          "status" => "Active",
          "type" => "Adhoc",
          "policyRules" => []
        })
      else
        puts "The #{platform_task_source_name} source already exists in the Kinetic Task database."
      end
    end

    # Update the identity store properties
    task_sdk.update_identity_store({
      "Identity Store" => "com.kineticdata.authentication.kineticcore.KineticCoreIdentityStore",
      "properties" => {
        "Kinetic Core Space Url" => "#{ce_server}/#{space_slug}",
        "Proxy Username (Space Admin)" => ce_integration_username,
        "Proxy Password (Space Admin)" => ce_integration_password
      }
    })

    # Update the authentication
    task_sdk.update_authentication({
      "authenticator" => "com.kineticdata.core.v1.authenticators.OAuthAuthenticator",
      "authenticationJsp" => "/WEB-INF/app/login.jsp",
      "properties" => {
        "Provider Name" => "Kinops Request CE",
        "Auto Redirect Login" => "Yes",
        "Authorize Endpoint" => "#{task_oauth_server}/#{space_slug}/app/oauth/authorize",
        "Token Endpoint" => "#{ce_server}/#{space_slug}/app/oauth/token",
        "Check Token Endpoint" => "#{ce_server}/#{space_slug}/app/oauth/check_token?token=",
        "Logout Redirect Location" => "#{task_oauth_server}/#{space_slug}/app/logout",
        "Client Id" => "kinetic-task",
        "Client Secret" => oauth_secret_task,
        "Redirect URI" => "#{task_oauth_redirect_server}/oauth",
        "Scope" => "full_access"
      }
    })

    # Locate Task Import Directory
    taskDir = "#{space_dir}/task"

    # Import space handlers
    Parallel.each(Dir[taskDir+"/handlers/*"]) do |handler|
      # skip the smtp email send handler (handled after this loop)
      next if handler.end_with?("smtp_email_send_v1.zip")

      handler_file = File.new(handler, 'rb')

      # try up to 3 times in case of time-outs
      tries = 3
      response = nil
      while tries > 0 do
        response = task_sdk.import_handler(handler_file, true)
        break if response.status == 200
        tries -= 1
        sleep 2
      end

      # if import was successful, set the handler properties
      if tries > 0
        # Update the Request CE Notification Template handler
        if File.basename(handler_file).start_with?("kinetic_request_ce_notification_template_send_v1")
          task_sdk.update_handler(File.basename(handler_file, ".zip"), {
            "properties" => {
              'smtp_server' => env["notification_template_handler"]["smtp_server"],
              'smtp_port' => env["notification_template_handler"]["smtp_port"],
              'smtp_tls' => env["notification_template_handler"]["smtp_tls"],
              'smtp_username' => env["notification_template_handler"]["smtp_username"],
              'smtp_password' => env["notification_template_handler"]["smtp_password"],
              'smtp_from_address' => env["notification_template_handler"]["smtp_from_address"],
              'api_server' => ce_server,
              'api_username' => ce_integration_username,
              'api_password' => ce_integration_password,
              'space_slug' => space_slug,
              'enable_debug_logging' => 'Yes'
            }
          })
        # update each Kinetic Request handler - need API to get list of info values?
        elsif File.basename(handler_file).start_with?("kinetic_request_ce")
          task_sdk.update_handler(File.basename(handler_file, ".zip"), {
            "properties" => {
              "api_server" => ce_server,
              "api_username" => ce_integration_username,
              "api_password" => ce_integration_password,
              "space_slug" => space_slug
            },
            "categories" => []
          })
        # update the Kinetic Task Tree Run v2 handler
        elsif File.basename(handler_file).start_with?("kinetic_task_tree_run_v2")
          task_sdk.update_handler(File.basename(handler_file, ".zip"), {
            "properties" => {
              "username" => ce_integration_username,
              "password" => ce_integration_password,
              "kinetic_task_location" => "#{task_server}",
              "signature_key" => task_access_key["identifier"],
              "signature_secret" => task_access_key["secret"],
              "enable_debug_logging" => "No"
            },
            "categories" => []
          })
        # update each Kinetic Task handler - need API to get list of info values?
        elsif File.basename(handler_file).start_with?("kinetic_task")
          task_sdk.update_handler(File.basename(handler_file, ".zip"), {
            "properties" => {
              "username" => ce_integration_username,
              "password" => ce_integration_password,
              "kinetic_task_location" => "#{task_server}",
              "enable_debug_logging" => "No"
            },
            "categories" => []
          })
        end
      end
    end

    # Update SMTP handler
    task_sdk.update_handler("smtp_email_send_v1", {
      "properties" => {
        "server" => env["smtp"]["server"],
        "port" => env["smtp"]["port"],
        "tls" => env["smtp"]["tls"],
        "username" => env["smtp"]["username"],
        "password" => env["smtp"]["password"]
      }
    })


    # Import trees
    Parallel.each(Dir[taskDir+"/trees/**/*"]) do |tree|
      unless File.directory?(tree)
        # Get the name of the directory
        source_name = File.dirname(tree).split("/").last
        # TODO: Kinetic Task is always included, provide a configurable array of
        #       source names that are also expected
        valid_sources = [ "Kinetic Task", ce_task_source_name ]
        valid_sources << platform_task_source_name if platform_task_source_name.to_s.size > 0
        valid_sources.each do |defined_source_name|
          # If the tree directory is the slugified version of the source name
          slugified_source_name = task_sdk.slugify(defined_source_name)
          if (source_name == slugified_source_name || source_name == slugified_source_name.gsub("-", ""))
            # update the source name to be the defined source name
            source_name = defined_source_name
            break
          end
        end
        # fix up the source name in the tree, otherwise the import will fail
        content = File.read(tree).sub(
          /<sourceName>(.*)<\/sourceName>/,
          "<sourceName>#{source_name}</sourceName>"
        )
        # save the file
        File.write(tree, content)
        # import the file
        task_sdk.import_tree(File.new(tree, 'rb'), true)
      end
    end

    # Import routines
    Parallel.each(Dir[taskDir+"/routines/*"]) do |routine|
      unless File.directory?(routine)
        task_sdk.import_routine(File.new(routine, 'rb'), true)
      end
    end

    # Create Groups
    Parallel.each(Dir[taskDir+"/groups/*"]) do |file|
      group = JSON.parse(File.read(file))
      task_sdk.add_group(group['name']) if task_sdk.find_group(group['name']).status == 404
    end

    # Create Policy Rules
    Parallel.each(Dir[taskDir+"/policyRules/*"]) do |file|
      policy_rule = JSON.parse(File.read(file))
      if task_sdk.find_policy_rule(policy_rule).status == 404
        # create the policy rule
        task_sdk.add_policy_rule(policy_rule)
      else
        # update the policy rule
        task_sdk.update_policy_rule(policy_rule, policy_rule)
      end
    end

    # Set the default policy rule
    task_sdk.update_system_policy_rule("Allow All")

    # Create Categories
    Parallel.each(Dir[taskDir+"/categories/*"]) do |file|
      category = JSON.parse(File.read(file))
      if task_sdk.find_category(category['name']).status == 404
        # create the category
        task_sdk.add_category(category)
      else
        # update the category with the handlers, trees, and policy rules
        task_sdk.update_category(category['name'], category)
      end
    end


    # Clean up the sample data
    task_sdk.delete_group("Administrators")
    task_sdk.delete_group("Managers")
    task_sdk.delete_user("Adam Administrator")
    task_sdk.delete_user("Mary Manager")
    task_sdk.delete_policy_rule({ "type"=>"Console Access", "name"=>"Member of Administrators" })
    task_sdk.delete_policy_rule({ "type"=>"Console Access", "name"=>"Member of Administrators or Managers" })

    # Create or update the API access key
    if task_sdk.find_access_key(task_access_key['identifier']).status == 404
      task_sdk.add_access_key(task_access_key)
    else
      task_sdk.update_access_key(task_access_key['identifier'], task_access_key)
    end

    # Create or update the API - Valid Signature policy rule
    if task_sdk.find_policy_rule({ "type" => "API Access", "name" => "Valid Signature" }).status == 404
      task_sdk.add_policy_rule(signature_policy_rule)
    end
    # Add the Valid Signature policy rule to the Request CE source
    task_sdk.add_policy_rule_to_source(
      signature_policy_rule['type'], signature_policy_rule['name'], ce_task_source_name
    )

    # Update engine properties
    task_sdk.update_engine({
      "Max Threads" => "1",
      "Sleep Delay" => "1",
      "Trigger Query" => "'Selection Criterion'=null"
    })

    # Update the session configuration for new installations, or upgrades from pre 4.1
    begin
      # Retrieve the existing session configuration
      session_config = task_sdk.find_session_configuration
      if session_config.content["timeout"] != "43200"
        # Update the Task session timeout to 30 days
        task_sdk.update_session_configuration({ "timeout" => "43200" })
      end
    rescue
      puts "Unsupported, ability to configure session timeout was added in Task 4.1.0"
    end
  else
    puts "The #{ce_task_source_name} source already exists, skipping Task import."
  end
end

#--------------------------------------------------------------------------
# Bridgehub
#--------------------------------------------------------------------------
if options.configureBH

  bridgehub_sdk = KineticSdk::Bridgehub.new({
    app_server_url: env["bridgehub"]["server"],
    username: env["bridgehub"]["credentials"]["username"],
    password: env["bridgehub"]["credentials"]["password"],
    options: { log_level: log_level }
  })

  import = false

  # Check if the Bridge already exists
  bridge_response = bridgehub_sdk.find_bridge(bridge_slug)
  if (bridge_response.status == 404 || (bridge_response.status == 200 && options.import_overwrite))
    import = true
  end

  if import
    if bridge_response.status == 404
      bridgehub_sdk.add_bridge({
        "adapterClass" => "com.kineticdata.bridgehub.adapter.kineticcore.KineticCoreAdapter",
        "name" => "CE - #{space_name}",
        "slug" => bridge_slug,
        "ipAddresses" => "*",
        "useAccessKeys" => "true",
        "properties" => {
          "Username" => ce_integration_username,
          "Password" => ce_integration_password,
          "Kinetic Core Space Url" => "#{ce_server}/#{space_slug}"
        }
      })
    else
      bridgehub_sdk.update_bridge(bridge_slug, {
        "properties" => {
          "Username" => ce_integration_username,
          "Password" => ce_integration_password,
          "Kinetic Core Space Url" => "#{ce_server}/#{space_slug}"
        }
      })
    end

    # Delete all Bridge access keys and create a new one
    (bridgehub_sdk.find_access_keys(bridge_slug).content["accessKeys"] || []).each do |access_key|
      bridgehub_sdk.delete_access_key(bridge_slug, access_key["id"])
    end

    # Create a new bridge access key
    bridge_access_key = bridgehub_sdk.add_access_key(bridge_slug, {
      "description" => "Kinetic Request CE space #{space_name} (#{space_slug})"
    }).content["accessKey"]

    # Log into the Space with the kdadmin user
    requestce_sdk_space = KineticSdk::RequestCe.new({
      app_server_url: ce_server,
      space_slug: space_slug,
      username: ce_credentials_space_admin["username"],
      password: ce_credentials_space_admin["password"],
      options: { log_level: log_level }
    })

    # Update Request CE with the Bridge Access Key information
    requestce_sdk_space.update_bridge("Kinetic Core", {
      "key" => bridge_access_key["id"],
      "secret" => bridge_access_key["secret"]
    })
  else
    puts "The #{bridge_slug} bridge already exists, skipping BridgeHub import."
  end

end


#--------------------------------------------------------------------------
# Filehub
#--------------------------------------------------------------------------
if options.configureFH

  # Create the Filehub filestore
  filehub_sdk = KineticSdk::Filehub.new({
    app_server_url: env["filehub"]["server"],
    username: env["filehub"]["credentials"]["username"],
    password: env["filehub"]["credentials"]["password"],
    options: { log_level: log_level }
  })

  import = false

  # Check if the Filestore already exists
  filestore_response = filehub_sdk.find_filestore(filestore_slug)
  if (filestore_response.status == 404 || (filestore_response.status == 200 && options.import_overwrite))
    import = true
  end

  if import
    if filestore_response.status == 404
      filehub_sdk.add_filestore({
        "adapterClass" => "com.kineticdata.filehub.adapters.local.LocalFilestoreAdapter",
        "name" => "CE - #{space_name}",
        "slug" => filestore_slug,
        "properties" => {
          "Directory" => filestore_data_location
        }
      })
    else
      filehub_sdk.update_filestore(filestore_slug, {
        "properties" => {
          "Directory" => filestore_data_location
        }
      })
    end

    # Delete all Filestore access keys and create a new one
    (filehub_sdk.find_access_keys(filestore_slug).content["accessKeys"] || []).each do |access_key|
      filehub_sdk.delete_access_key(filestore_slug, access_key["id"])
    end

    # Create a new filestore access key
    filestore_access_key = filehub_sdk.add_access_key(filestore_slug, {
      "description" => "Kinetic Request CE space #{space_name} (#{space_slug})"
    }).content["accessKey"]

    # Log into the Space with the kdadmin user
    requestce_sdk_space = KineticSdk::RequestCe.new({
      app_server_url: ce_server,
      space_slug: space_slug,
      username: ce_credentials_space_admin["username"],
      password: ce_credentials_space_admin["password"],
      options: { log_level: log_level }
    })

    # Update Request CE with the Filehub information
    requestce_sdk_space.update_space({
      "filestore" => {
        "filehubUrl" => filehub_server,
        "key" => filestore_access_key["id"],
        "secret" => filestore_access_key["secret"],
        "slug" => filestore_slug
      }
    })
  else
    puts "The #{filestore_slug} filestore already exists, skipping FileHub import."
  end
end
