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
# 3. ruby import-fake-data.rb \
#      -s space-slug \
#      -c <config-file-name.yaml> \
################################################################################

require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'time'
require 'yaml'
require'csv'
require 'faker'

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

      opts.on("-s SPACE_SLUG",
              "The slug of the Space to import to") do |slug|
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

require 'slugify'
require 'parallel'
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
log_level = ENV['SDK_LOG_LEVEL'] || env['sdk_log_level'] || "info"
space_slug = options.space_slug

ce_server = env["ce"]["server"]
ce_credentials_space_admin = {
  "username" => env["ce"]["space_admin_credentials"]["username"],
  "password" => env["ce"]["space_admin_credentials"]["password"]
}

# Set Script Variables and Constants
@fieldKey = 1
@forms = []
@form_exists = true;
@number_to_import = 100_000
form_name = "People"
form_slug = "people"
fields = ['First Name', 'Last Name', 'City', 'State', 'Zip', 'Age']

# Log into the Space with the Space Admin user
requestce_sdk_space = KineticSdk::RequestCe.new({
  app_server_url: ce_server,
  space_slug: space_slug,
  username: ce_credentials_space_admin["username"],
  password: ce_credentials_space_admin["password"],
  options: { log_level: log_level }
})

# Keep track of errors and total submissions imported
total = 0
errors = []

if requestce_sdk_space.find_datastore_form(form_slug).status == 404
  @form_exists = false
end

if !@form_exists
  form = build_form(form_name, form_slug)
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
    'City'              => Faker::Address.city,
    'State'             => Faker::Address.state,
    'Zip'               => Faker::Address.zip,
    'Age'               => Faker::Number.between(1, 100),
  }
end
start = Time.now

Parallel.each(@number_to_import.times, in_threads: 12) do |i|
  response = requestce_sdk_space.add_datastore_submission(form_slug, {"values" => build_data})
  response.status === 200 ? total +=1 : errors.push(response.content_string)
end

finish = Time.now
puts "Start Time: " + start.inspect
puts "End Time: " + finish.inspect
puts "Total Time (hours): " + ((finish - start) / 3600).to_s
puts "Total Imported:" + total.to_s
puts "Errors:"

errors.each do |error|
  puts error.to_s
end
