###################################  TO RUN  ###################################
#
# This driver file assumes the Kinetic SDK is located in the relative directory:
#   - vendor/kinetic-sdk-rb
#
# Before running this, be sure to install the faker gem on the machine 
# running this script
#
#
# 1. Ensure ruby (or jruby) is installed
# 2. Ensure the Faker gem is installed (gem install faker)
# 3. Create a yaml file in the 'config' directory (will be omitted from git)
#      - configure for your Request CE server
# 4. ruby import-datastore-submissions.rb \
#      -c <config-file-name.yaml> \
#      -s <space-slug> \
#      [-n number_of_submissions (default 100)] \
#      [-t number_of_threads (default 1)] \
#      [-d datastore_form_name (default People)] \
#      [-f fields (comma-separated list of field names)] \
#      [-u unique_indexes (semicolon-separated list of unique indexes)]
################################################################################

require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'time'
require 'yaml'
require 'thread'


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
      opts.banner = "Usage: #{$0} [options]"

      opts.separator ""

      opts.on("-c CONFIG_FILE",
              "REQUIRED - The config file to use for the export (must be in ./config directory)") do |cfg_file|
        options.cfg = cfg_file
      end

      opts.on("-s SPACE_SLUG",
              "REQUIRED - The slug of the Space to import to") do |slug|
        options.space_slug = slug
      end

      opts.on("-d DATASTORE_NAME",
              "Datastore Name (default People)") do |datastore_name|
        options.datastore_name = datastore_name
      end

      opts.on("-f FIELDS", Array,
              "Fields (comma-separated list of field names)") do |fields|
        options.fields = fields
      end

      opts.on("-u UNIQUE_INDEXES",
              "Unique Indexes (semicolon-separated list of unique indexes)") do |unique_indexes|
        options.unique_indexes = unique_indexes
      end

      opts.on("-n NUMBER_OF_SUBMISSIONS", OptionParser::DecimalInteger,
              "The number of submissions to import (default 100)") do |number_of_submissions|
        options.number_of_submissions = number_of_submissions
      end

      opts.on("-t NUMBER_OF_THREADS", OptionParser::DecimalInteger,
              "The number of submission threads (default 1)") do |number_of_threads|
        options.number_of_threads = number_of_threads
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

#=================================
# INITIALIZE
#=================================

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

require "#{pwd}/helpers"

# Parse options from command line arguments
options = ImportOptions.parse(ARGV)


#=================================
# VALIDATE COMMAND LINE ARGUMENTS
#=================================

# Validate the options
unless options.cfg
  puts "The configuration file must be provided. Run `ruby #{$0} --help`"
  exit
end
unless options.space_slug
  puts "The space slug must be provided. Run `ruby #{$0} --help`"
  exit
end


#=================================
# LOAD THE CONFIGURATION AND ARGS
#=================================

# Get the configuration file
config = nil
begin
  config_file = "#{pwd}/config/#{options.cfg}"
  config = YAML.load(open(config_file).read)
rescue
  puts "The configuration file #{options.cfg} does not exist."
  exit
end

# Set variables from the config file
ce_server = config["ce"]["server"]
ce_credentials_space_admin = {
  "username" => config["ce"]["space_admin_credentials"]["username"],
  "password" => config["ce"]["space_admin_credentials"]["password"]
}
sdk_log_level = ENV['SDK_LOG_LEVEL'] || config['sdk_log_level'] || "off"

# Set variables from the command line arguments
space_slug = options.space_slug
number_to_import = options.number_of_submissions || 100
threads = options.number_of_threads || 1

default_form = "People"
default_fields = ['First Name', 'Last Name', 'Street', 'City', 'State', 'Zip', 'Age', 'Phone']
default_unique_indexes = []

form_name = options.datastore_name || default_form
form_slug = form_name.slugify
fields = options.fields || default_fields
unique_indexes = options.unique_indexes.nil? ? 
  default_unique_indexes : 
  options.unique_indexes.split(";")


# Log into the Space with the Space Admin user
requestce_sdk_space = KineticSdk::RequestCe.new({
  app_server_url: ce_server,
  space_slug: space_slug,
  username: ce_credentials_space_admin["username"],
  password: ce_credentials_space_admin["password"],
  options: { log_level: sdk_log_level }
})

#=================================
# DATASTORE FORM
#=================================

if requestce_sdk_space.find_datastore_form(form_slug).status == 404
  datastore = build_form_with_fields(form_name, form_slug, fields)

  response = requestce_sdk_space.add_datastore_form(datastore)
  raise StandardError.new("ERROR: Datastore form could not be created!") if response.status != 200

  # Get the datastore form and add the unique indexes
  indexes = requestce_sdk_space.find_datastore_form(form_slug, {
    "include" => "indexDefinitions"
  }).content['form']['indexDefinitions']
  # For each defined unique index, convert existing index to unique index
  updated_indexes = indexes.map do |index|
    if unique_indexes.include?(index['parts'].join(','))
      index['unique'] = true
      index['status'] = 'New'
    end
    index
  end
  # Update datastore form
  requestce_sdk_space.update_datastore_form(form_slug, {
    "indexDefinitions" => updated_indexes
  })
  # Retrieve the datastore again to get the updated index names
  indexes = requestce_sdk_space.find_datastore_form(form_slug, {
    "include" => "indexDefinitions"
  }).content['form']['indexDefinitions']
  # Build the updated datastore indexes
  updated_indexes = []
  indexes.each { |index| updated_indexes << index['name'] if index['status'] == 'New' }
  requestce_sdk_space.build_datastore_form_indexes(form_slug, updated_indexes)
end

#=================================
# DATASTORE SUBMISSIONS
#=================================

# instance variables to track progress
submissions = 0
errors = []

start = Time.now
mutex = Mutex.new
Parallel.map(
    1..number_to_import, 
    in_threads: threads, 
    preserve_results: true, 
    progress: "Importing #{number_to_import} submissions to #{form_slug}") do |i|
  response = requestce_sdk_space.add_datastore_submission(form_slug, {
    "values" => build_submission_data(fields)
  })
  mutex.synchronize do 
    response.status == 200 ? submissions += 1 : errors.push(response)
  end
end

finish = Time.now
puts ""

#===========================
# SUMMARY
#===========================

duration_seconds = finish - start
duration_minutes = duration_seconds / 60
duration_hours = duration_minutes / 60

puts "#{'-'*80}\n Results: #{form_name} (#{form_slug})\n#{'-'*80}"
puts "Start Time: #{start.inspect}"
puts "End Time: #{finish.inspect}"
puts "Threads: #{threads}"

puts "Duration:"
puts(sprintf "  %.3f hrs", duration_hours)
puts(sprintf "  %.3f mins", duration_minutes)
puts(sprintf "  %.3f secs", duration_seconds)

puts "Submissions: (#{submissions})"
puts(sprintf "  %.3f submissions/hr", submissions / duration_hours)
puts(sprintf "  %.3f submissions/min", submissions / duration_minutes)
puts(sprintf "  %.3f submissions/sec", submissions / duration_seconds)

puts "Errors (#{errors.size}):"

errors.each do |error|
  puts "  ERROR: #{error.inspect}"
end
puts ""
