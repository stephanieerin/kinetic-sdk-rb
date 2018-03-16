###################################  TO RUN  ###################################
#
# This driver file assumes the Kinetic SDK is located in the relative directory:
#   - vendor/kinetic-sdk-rb
#
# If you have multiple handler types configured in your config.yaml file and you
# only want to update one, you can provide a handler_prefix. Only handlers
# with that handler prefix will be updated.
#
#
# 1. Ensure ruby (or jruby) is installed
# 2. Create a yaml file in the 'config' directory (will be omitted from git)
#      - add / edit the info values for the handlers you would like to update
# 3. ruby set-info-values.rb \
#      -p <handler_prefix> \
#      -c <config-file-name.yaml> \
################################################################################

require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'time'
require 'yaml'

class ImportOptions

  #
  # Return a structure describing the options.
  #
  def self.parse(args)

    args << '-h' if args.empty?

    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: set-info-values.rb [options]"

      opts.separator ""

      opts.on("-p HANDLER_PREFIX",
              "The prefix of the handlers to update") do |prefix|
        options.handler_prefix = prefix
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
options = ImportOptions.parse(ARGV)

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

# SDK Logging
log_level = ENV['SDK_LOG_LEVEL'] || env['sdk_log_level'] || "info"

#--------------------------------------------------------------------------
# Task
#--------------------------------------------------------------------------

task_sdk = KineticSdk::Task.new(
  app_server_url: env["task"]["server"],
  username: env["task"]["credentials"]["username"],
  password: env["task"]["credentials"]["password"],
  options: {
    log_level: log_level
  }
)

# Handlers to reset and their info values
handlers_to_update = options.handler_prefix ? env["handlers_to_update"].reject {|k| k != options.handler_prefix} : env["handlers_to_update"]

# Get list of all Handlers
handlers = task_sdk.find_handlers({"include" => "properties"}).content["handlers"]

# Loop over each handler retrieved
handlers.each do |handler|

  handlers_to_update.keys.each do |prefix|

    # Check to see if handler should be updated
    if handler["definitionId"].start_with?(prefix)

      puts "Updating handler: #{handler['name']}"

      # Transform Current Info Values into Hash
      currentProperties = Hash[handler["properties"].collect { |info| [info["name"], info["value"]] } ]

      # Merge Current Info Values with New Info Values
      updatedProperties = currentProperties.merge(handlers_to_update[prefix])

      # Update the handler's info values using the values in the config file
      task_sdk.update_handler(handler["definitionId"], {
        "properties" => updatedProperties
      })

      puts "Successfully updated handler: #{handler['name']}"
    end
  end
end
