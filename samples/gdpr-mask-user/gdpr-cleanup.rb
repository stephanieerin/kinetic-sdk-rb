###################################  TO RUN  ###################################
#
# This driver file assumes the Kinetic SDK is located in the relative directory:
#   - vendor/kinetic-sdk-rb
#
#
# 1. Ensure ruby (or jruby) is installed
# 2. Create a yaml file in the 'config' directory (will be omitted from git)
# 3. ruby gdpr-cleanup.rb \
#      -s <space-slug> \
#      -c <config-file-name.yaml> \
################################################################################

require 'erb'
require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'pp'
require 'yaml'


class GDPROptions

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

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: gdpr-cleanup.rb [options]"

      opts.separator ""

      opts.on("-s SPACE_SLUG",
              "The slug of the new Space to import") do |slug|
        options.space_slug = slug
      end

      opts.on("-c CONFIG_FILE",
              "The config file to use for the export (must be in ./config directory)") do |cfg_file|
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
options = GDPROptions.parse(ARGV)

# Get Space Name / Slug and Export Space Slug
space_slug = options.space_slug

# Get the environment file
config_file = "#{pwd}/config/#{options.cfg}"
env = nil
begin
  env = YAML.load(ERB.new(open(config_file).read).result(binding))
rescue
  puts "There was a problem loading the configuration file #{options.cfg}: #{$!}"
  exit
end

# SDK Logging
log_level = ENV['SDK_LOG_LEVEL'] || env['sdk_log_level'] || "info"

# Request CE
ce_server = env["ce"]["server"]
ce_task_source_name = env["ce"]["task_source_name"]

# Get the Request CE space user credentials from an external file
ce_credentials_space_admin = {
  "username" => env["ce"]["space_admin_credentials"]["username"],
  "password" => env["ce"]["space_admin_credentials"]["password"]
}

# Get List of Strings to Mask from Config File
strings_to_mask = env["strings_to_mask"]

# Get Username to search for submissions by
user_to_mask = env["user_to_mask"]

# Get Masked Replacement Value
masked_value = env["masked_replacement_value"]

# Task
task_server = env["task"]["server"]

masked_submission_ids = []

#--------------------------------------------------------------------------
# Request CE
#--------------------------------------------------------------------------

# Log into the Space with the Space Admin user
requestce_sdk_space = KineticSdk::RequestCe.new({
  app_server_url: ce_server,
  space_slug: space_slug,
  username: ce_credentials_space_admin["username"],
  password: ce_credentials_space_admin["password"],
  options: { log_level: log_level }
})

puts "Searching for the following strings: #{strings_to_mask.inspect}"

# Loop over each kapp and search for submissions created by the user to mask
requestce_sdk_space.find_kapps.content['kapps'].each do |kapp|
  puts "Searching for Submissions made by user: \"#{user_to_mask}\" in the \"#{kapp['name']}\" kapp"
  kapp_submissions = requestce_sdk_space.find_kapp_submissions(kapp['slug'], {
    "q" => "createdBy=\"#{user_to_mask}\"",
    "include" => "details,values"
    }).content['submissions']

  # If submissions were found in the kapp, loop over each one and mask the properties and values
  if kapp_submissions.size > 0
    kapp_submissions.each do |submission|
      maskedSubmission = submission
      maskedSubmission.each_pair do |prop, value|
        if prop == "values"
          value.each_pair do |field, fieldValue|
            if strings_to_mask.include? fieldValue
              maskedSubmission["values"][field] = masked_value
            end
          end
        else
          if strings_to_mask.include? value
            maskedSubmission[prop] = masked_value
          end
        end
      end
      puts "Masking Submission with id \"#{maskedSubmission["id"]}\" in the \"#{kapp['name']}\" kapp"
      # Keep track of this submission id so we can use it when cleaning up task data
      masked_submission_ids.push(maskedSubmission["id"])
      requestce_sdk_space.patch_existing_submission(maskedSubmission["id"], maskedSubmission)
    end
  else
    puts "No submissions made by user: \"#{user_to_mask}\" in the \"#{kapp['name']}\" kapp"
  end
end

#Mask the User in the CE System
masked_user = requestce_sdk_space.find_user(user_to_mask, {"include" => "details,attributesMap,profileAttributesMap"}).content["user"]
masked_user.each_pair do |prop, value|
  # Skip the username as you can't change users currently
  if prop == "username"
    next
  # Disable the user account
  elsif prop == "enabled"
    masked_user[prop] = false
  # Clean up Attributes
  elsif prop == "attributesMap" || prop == "profileAttributesMap"
    value.each_pair do |attrName, attrValues|
      updatedAttribute = attrValues.map {|v| strings_to_mask.include?(v) ? masked_value : v}
      masked_user[prop][attrName] = updatedAttribute
    end
  # Clean up the rest of the User Props (display name, email...etc)
  else
    if strings_to_mask.include? value
      masked_user[prop] = masked_value
    end
  end
end
# Update the user
puts "Disabling and Masking the user \"#{masked_user["username"]}\""
requestce_sdk_space.update_user(masked_user["username"], masked_user)

# Output the submission ID's that were updated for auditing
puts "The following Submissions were updated"
puts masked_submission_ids.inspect

#--------------------------------------------------------------------------
# Task
#--------------------------------------------------------------------------

# For Kinetic Task, you will want to clean up data in the following tables/columns
# Table: source_data, Columns: content
# Table: executions, Columns: inputs
# Table: tasks, Columns: deferred_results, results
# Table: task_messages, Columns: text
# Table: task_exceptions, Columns: text
# Table: triggers, Columns: message, results
