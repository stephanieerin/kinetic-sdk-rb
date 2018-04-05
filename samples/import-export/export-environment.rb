###################################  TO RUN  ###################################
#
# This driver file assumes the Kinetic SDK is located in the relative directory:
#   - vendor/kinetic-sdk-rb
#
#
# 1. Ensure ruby (or jruby) is installed
# 2. Create a yaml file in the 'config' directory (will be omitted from git)
# 3. Ensure the 'exports' directory exists
# 4. ruby export-environment.rb \
#      -s <space-slug> \
#      -c <config-file-name.yaml> \
#      -t <type of export>
################################################################################

require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'time'
require 'yaml'

class ExportOptions

  #
  # Return a structure describing the options.
  #
  def self.parse(args)

    args << '-h' if args.empty?

    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.space_slug = nil

    opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: export-core.rb [options]"

    opts.separator ""

    opts.on("-s SPACE_SLUG",
            "The slug of the Space to export") do |slug|
      options.space_slug = slug
    end

    opts.separator ""

    opts.on("-t EXPORT TYPE",
            "The type of export to run (ce,task,all") do |type|
      if type.to_s.downcase == "ce"
        options.exportCE = true
        options.exportTask = false
      elsif type.to_s.downcase == "task"
        options.exportCE = false
        options.exportTask = true
      else
        options.exportCE = true
        options.exportTask = true
      end
    end

    opts.separator ""

    opts.on("-c CONFIG_FILE",
            "The config file to use for the export") do |cfg_file|
      options.cfg = cfg_file
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

# Parse options from command line arguments
options = ExportOptions.parse(ARGV)

# Build mapping of kapp/forms to export submissions for
formsToExport = {"admin" => [
  'notification-template-dates',
  'notification-data',
  'registered-images'
]}
# Build an Array of All attributes to remove from JSON export
# authStrategy is for webhooks / key is for bridges
attrsToDelete = ["createdAt","createdBy","updatedAt","updatedBy","closedAt","closedBy","id","authStrategy","key","handle"]

# Get space slug from Arguments
space_slug = options.space_slug
space_name = nil

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

log_level = ENV['SDK_LOG_LEVEL'] || env['sdk_log_level'] || "info"

# Build and move to the Export Directory for this space
space_dir = "#{pwd}/exports/#{space_slug}"
FileUtils.mkdir_p(space_dir, :mode => 0700) unless Dir.exist?(space_dir)
Dir.chdir(space_dir)

if options.exportCE
  #--------------------------------------------------------------------------
  # Request CE
  #--------------------------------------------------------------------------

  # CE
  ce_server = env["ce"]["server"]
  # Get the Request CE configurator user credentials from the config file
  ce_credentials = {
    "username" => env["ce"]["system_credentials"]["username"],
    "password" => env["ce"]["system_credentials"]["password"]
  }
  # Get the Request CE space user credentials from the config file
  ce_credentials_space_admin = {
    "username" => KineticSdk::Utils::Random.simple,
    "password" => KineticSdk::Utils::Random.simple
  }
  ce_task_source_name = env["ce"]["task_source_name"]

  # Connect to the CE System API
  requestce_sdk = KineticSdk::RequestCe.new({
    app_server_url: ce_server,
    username: ce_credentials["username"],
    password: ce_credentials["password"],
    options: { log_level: log_level }
  })

  # flag to indicate the space needs to be updated instead of created
  space_exists = false

  # Export the space if it exists
  if requestce_sdk.space_exists?(space_slug)
    puts "Exporting Space: #{space_slug}"

    # Create an export user
    puts "Creating an export user in the \"#{space_slug}\" Request CE space."
    requestce_sdk.add_user({
      "space_slug" => space_slug,
      "username" => ce_credentials_space_admin["username"],
      "displayName" => ce_credentials_space_admin["username"],
      "password" => ce_credentials_space_admin["password"],
      "enabled" => true,
      "spaceAdmin" => true
    })

    # Log into the Space with the export user
    requestce_sdk = KineticSdk::RequestCe.new({
      app_server_url: ce_server,
      space_slug: space_slug,
      username: ce_credentials_space_admin["username"],
      password: ce_credentials_space_admin["password"],
      options: { log_level: log_level }
    })

    # Export Space - Returns the entire Space definition including all kapps
    space = requestce_sdk.export_space.content['space']
    space_name = space['name']

    ## SPACE ##
    ceDir = "#{space_dir}/ce"
    Dir.mkdir(ceDir, 0700) unless Dir.exist?(ceDir)
    Dir.chdir(ceDir)

    # Delete all Existing Files in this Directory (if we delete an item from an exported space we want it deleted)
    FileUtils.rm_rf Dir.glob("#{ceDir}/*")

    # Create space.json (All Arrays except attributes and security policies should be excluded)
    includeWithSpace = ['attributes', 'securityPolicies'];
    spaceJson = JSON.pretty_generate(space.reject {|k,v| v.is_a?(Array) && !includeWithSpace.include?(k)})
    File.open("#{ceDir}/space.json", 'w') { |file| file.write(spaceJson) }

    # Loop over the rest of the space objects and create files for them
    hasOwnFolder = ['kapps', 'bridges', 'models', 'teams']
    spaceObjects = space.reject {|k,v| !v.is_a?(Array) || includeWithSpace.include?(k) || hasOwnFolder.include?(k)}
    spaceObjects.each do | k, v |
      File.open("#{ceDir}/#{k.slugify}.json", 'w') { |file| file.write(JSON.pretty_generate(v)) }
    end

    ## BRIDGES ##
    puts "Building Bridge Directory Structure"
    Dir.mkdir("#{ceDir}/bridges", 0700) unless Dir.exist?("#{ceDir}/bridges")
    Dir.chdir("#{ceDir}/bridges")

    Dir.mkdir("#{ceDir}/bridges/bridges", 0700) unless Dir.exist?("#{ceDir}/bridges/bridges")
    Dir.chdir("#{ceDir}/bridges/bridges")
    space["bridges"].each do |obj|
      File.open("#{ceDir}/bridges/bridges/#{obj['name'].slugify}.json", 'w') { |file| file.write(JSON.pretty_generate(obj)) }
    end

    ## BRIDGE MODELS ##
    Dir.mkdir("#{ceDir}/bridges/bridgeModels", 0700) unless Dir.exist?("#{ceDir}/bridges/bridgeModels")
    Dir.chdir("#{ceDir}/bridges/bridgeModels")
    space["models"].each do |obj|
      File.open("#{ceDir}/bridges/bridgeModels/#{obj['name'].slugify}.json", 'w') { |file| file.write(JSON.pretty_generate(obj)) }
    end


    ## TEAMS ##
    puts "Building Teams Directory Structure"
    Dir.mkdir("#{ceDir}/teams", 0700) unless Dir.exist?("#{ceDir}/teams")
    Dir.chdir("#{ceDir}/teams")
    teams_array = requestce_sdk.find_teams({"include" => "details,attributes"}).content["teams"]
    teams_array.each do |obj|
      File.open("#{ceDir}/teams/#{obj['name'].slugify}.json", 'w') { |file| file.write(JSON.pretty_generate(obj)) }
    end

    ## KAPPS ##
    puts "Building Kapp Directory Structure"
    # Loop over Each Kapp
    space["kapps"].each do |kapp|
      # Create a Kapp Directory
      kappDir = "#{ceDir}/kapp-#{kapp['slug']}"
      Dir.mkdir(kappDir, 0700) unless Dir.exist?(kappDir)
      Dir.chdir(kappDir)

      # Create kapp.json (All Arrays except attributes and security policies should be excluded)
      includeWithKapp = ['attributes', 'securityPolicies'];
      kappJson = JSON.pretty_generate(kapp.reject {|k,v| v.is_a?(Array) && !includeWithKapp.include?(k)})
      File.open("#{kappDir}/kapp.json", 'w') { |file| file.write(kappJson) }

      # Loop over the rest of the kapp objects and create files for them
      propsToExlucde = ['categorizations', 'fields']
      kappObjects = kapp.reject {|k,v| !v.is_a?(Array) || includeWithKapp.include?(k) || propsToExlucde.include?(k)}
      kappObjects.each do | k, v |
        if k == "forms"
          Dir.mkdir("#{kappDir}/forms", 0700) unless Dir.exist?("#{kappDir}/forms")
          v.each do |form|
            File.open("#{kappDir}/forms/#{form['slug']}.json", 'w') { |file| file.write(JSON.pretty_generate(form)) }
          end
        else
          File.open("#{kappDir}/#{k.slugify}.json", 'w') { |file| file.write(JSON.pretty_generate(v)) }
        end
      end
    end

    ## TEAMS ##
    puts "Building Teams Directory Structure"
    Dir.mkdir("#{ceDir}/teams", 0700) unless Dir.exist?("#{ceDir}/teams")
    Dir.chdir("#{ceDir}/teams")
    teams_array = requestce_sdk.find_teams({"include" => "details,attributes"}).content["teams"]
    teams_array.each do |obj|
      File.open("#{ceDir}/teams/#{obj['name'].slugify}.json", 'w') { |file| file.write(JSON.pretty_generate(obj)) }
    end

    ## SUBMISSIONS ##
    puts "Exporting Submissions"

    # Loop over each Kapp in the forms to export map
    formsToExport.keys.each do |kappSlug|
      # Loop over each form slug in the formsToExport map for the given kapp
      formsToExport[kappSlug].each do |formSlug|
        # Build a data directory for the kapp
        dataDir = "#{ceDir}/kapp-#{kappSlug}/data"
        FileUtils.mkdir_p(dataDir, :mode => 0700)
        # Build params to pass to the retrieve_form_submissions method
        params = {"include" => "values", "limit" => 1000, "direction" => "ASC"}
        # Open the submissions file in write mode
        file = File.open("#{dataDir}/#{formSlug}.json", 'w');
        # Ensure the file is empty
        file.truncate(0)
        response = nil
        count = 0
        begin
          # Get submissions
          response = requestce_sdk.find_form_submissions(kappSlug, formSlug, params).content
          count += response["submissions"].size
          # Write each submission on its own line
          response["submissions"].each do |submission|
            # Append each submission (removing the submission unwanted attributes)
            file.puts(JSON.generate(submission.delete_if { |key, value| attrsToDelete.member?(key)}))
          end
          params['pageToken'] = response['nextPageToken']
          # Get next page of submissions if there are more
        end while !response.nil? && !response['nextPageToken'].nil?
        # Close the submissions file
        file.close()
      end
    end

    ################################################################
    ## MANIPULATE DATA FILES TO REMOVE DATES / UPDATED BY DETAILS ##
    ################################################################

    # Build an Array of All JSON files that were exported
    configFiles = Dir.glob("#{ceDir}/**/*.json")
    replacements = [ [space_name, "<Space Name>"], [space_slug, "<space-slug>"] ]

    puts "Stripping out Created/Updated Dates and Users"

    # loop over each file and remove the attributes we want to omit
    configFiles.each do |filename|
    # Submission Data is handled in the export
    unless filename.include?("/data/")
      filename.include?("/data/")
      json = JSON.parse(File.read("#{filename}"))

      # Check to see if the JSON object is an Array of Hashes (webhooks...etc)
      if json.kind_of?(Array)
        json.each do |element|
          if element.is_a?(Hash)
            element.delete_if { |key, value| attrsToDelete.member?(key)}
          end
        end
      else
        json.delete_if { |key, value| attrsToDelete.member?(key)}
      end

      # Scrub Discussion Id Attributes from export
      if json.kind_of?(Hash) && json.has_key?('attributes')
        json['attributes'].delete_if {|attr| attr['name'] == "Discussion Id"}
      end

      # Replace Space Name and Space Slug References
      updatedData = JSON.pretty_generate(json)
      replacements.each {|replacement| updatedData.gsub!(/\b(#{replacement[0]})\b/, replacement[1])}
        File.open("#{filename}", 'w') { |file| file.write(updatedData) }
      end
    end

    # Remove Export User
    requestce_sdk.delete_user({
      "space_slug" => space_slug,
      "username" => ce_credentials_space_admin["username"],
    })

    puts "CE Export Complete"
  end
end

if options.exportTask
  #--------------------------------------------------------------------------
  # Kinetic Task
  #--------------------------------------------------------------------------
  puts "Exporting Kinetic Task"

  task_server = env["task"]["server"]

  task_sdk = KineticSdk::Task.new(
    app_server_url: task_server,
    username: env["task"]["credentials"]["username"],
    password: env["task"]["credentials"]["password"],
    options: {
      export_directory: "#{space_dir}/task",
      log_level: log_level
    }
  )

  # Delete all Existing Files in this Directory
  # (if we delete an item from an exported engine we want it deleted)
  FileUtils.rm_rf Dir.glob("#{space_dir}/task/*")

  # Export all trees, routines, handlers, groups, policy rules and categories
  task_sdk.export_trees
  task_sdk.export_routines
  task_sdk.export_handlers
  task_sdk.export_groups
  task_sdk.export_policy_rules
  task_sdk.export_categories
  puts "Task Export Complete"
end
