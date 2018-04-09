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
# 2. Create a yaml file in the 'config' directory (will be omitted from git)
#      - add / edit the info values for the handlers you would like to update
# 3. ruby import-datastore-faked.rb \
#      -c <config-file-name.yaml> \
#      -s space-slug \
#      -n number_of_submissions (default 100) \
#      -t number_of_threads (default 1)
################################################################################

require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'time'
require 'yaml'
require 'faker'
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
      opts.banner = "Usage: import-fake-data.rb [options]"

      opts.separator ""

      opts.on("-c CONFIG_FILE",
              "The config file to use for the export (must be in ./config directory)") do |cfg_file|
        options.cfg = cfg_file
      end

      opts.on("-s SPACE_SLUG",
              "The slug of the Space to import to") do |slug|
        options.space_slug = slug
      end

      opts.on("-n NUMBER_OF_SUBMISSIONS", Integer,
              "The number of submissions to import (default 100)") do |number_of_submissions|
        options.number_of_submissions = number_of_submissions
      end

      opts.on("-t NUMBER_OF_THREADS", Integer,
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

#===========================
# INITIALIZE
#===========================

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

# Set variables from options and config file
sdk_log_level = ENV['SDK_LOG_LEVEL'] || env['sdk_log_level'] || "off"
space_slug = options.space_slug

ce_server = env["ce"]["server"]
ce_credentials_space_admin = {
  "username" => env["ce"]["space_admin_credentials"]["username"],
  "password" => env["ce"]["space_admin_credentials"]["password"]
}

# Set Script Variables and Constants
number_to_import = options.number_of_submissions || 100
threads = options.number_of_threads || 1

suffix = Time.now.to_i
form_name = "People #{suffix}"
form_slug = "people-#{suffix}"
fields = ['First Name', 'Last Name', 'Street', 'City', 'State', 'Zip', 'Age', 'Phone']

# Log into the Space with the Space Admin user
requestce_sdk_space = KineticSdk::RequestCe.new({
  app_server_url: ce_server,
  space_slug: space_slug,
  username: ce_credentials_space_admin["username"],
  password: ce_credentials_space_admin["password"],
  options: { log_level: sdk_log_level }
})

#===========================
# FORM
#===========================
if requestce_sdk_space.find_datastore_form(form_slug).status == 404
  form = build_form(form_name, form_slug)
  @fieldKey = 1
  fields.each do |field|
    form['pages'][0]['elements'].unshift(build_field_element(field))
    @fieldKey += 1
  end

  requestce_sdk_space.add_datastore_form(form)
end

def build_data
  {
    'First Name'        => Faker::Name.first_name,
    'Last Name'         => Faker::Name.last_name,
    'Street'            => Faker::Address.street_address,
    'City'              => Faker::Address.city,
    'State'             => Faker::Address.state,
    'Zip'               => Faker::Address.zip,
    'Age'               => Faker::Number.between(1, 100),
    'Phone'             => Faker::PhoneNumber.phone_number
  }
end

#===========================
# SUBMISSIONS
#===========================

# instance variables to share across threads
@total = 0
@errors = []

start = Time.now
mutex = Mutex.new
Parallel.map(
    1..number_to_import, 
    in_threads: threads, 
    preserve_results: true, 
    progress: "Importing #{number_to_import} submissions") do |i|
  response = requestce_sdk_space.add_datastore_submission(form_slug, {"values" => build_data})
  mutex.synchronize do 
    response.status == 200 ? @total += 1 : @errors.push(response)
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

puts "-" * 80
puts " Results: "
puts "-" * 80
puts "Start Time: #{start.inspect}"
puts "End Time: #{finish.inspect}"
puts "Threads: #{threads}"

puts "Duration:"
puts(sprintf "  %.3f hrs", duration_hours)
puts(sprintf "  %.3f mins", duration_minutes)
puts "  #{duration_seconds} secs"

puts "Submissions: (#{@total})"
puts(sprintf "  %.3f submissions/hour", @total / duration_hours)
puts(sprintf "  %.3f submissions/minute", @total / duration_minutes)
puts(sprintf "  %.3f submissions/second", @total / duration_seconds)

puts "Errors (#{@errors.size}):"

@errors.each do |error|
  puts "  ERROR: #{error.inspect}"
end
puts ""
