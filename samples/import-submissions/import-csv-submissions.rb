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
# 3. ruby import-submissions.rb \
#      -s <space slug> \
#      -k <kapp slug> \ (if no kapp slug, assume this is a datastore)
#      -c <config-file-name.yaml> \
################################################################################

require 'fileutils'
require 'json'
require 'optparse'
require 'ostruct'
require 'time'
require 'yaml'
require'csv'

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

      opts.on("-k KAPP_SLUG",
              "The slug of the Kapp to import to") do |slug|
        options.kapp_slug = slug
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
kapp_slug = options.kapp_slug
is_datastore = kapp_slug.nil? ? true : false

ce_server = env["ce"]["server"]
ce_credentials_space_admin = {
  "username" => env["ce"]["space_admin_credentials"]["username"],
  "password" => env["ce"]["space_admin_credentials"]["password"]
}

# Set Script Variables and Constants
DATA_DIR = "#{pwd}/data"
COMMON_DELIMITERS = ['","',"\"\t\"",'"|"',]
@fieldKey = 1
@forms = []

# Log into the Space with the Space Admin user
requestce_sdk_space = KineticSdk::RequestCe.new({
  app_server_url: ce_server,
  space_slug: space_slug,
  username: ce_credentials_space_admin["username"],
  password: ce_credentials_space_admin["password"],
  options: { log_level: log_level }
})

#Loop over each file in the data directory
Dir["#{DATA_DIR}/*"].map do |data_file|
  # Determine the files delimiter
  del = find_delimiter(data_file)
  form_exists = true;
  # Calculate the form name based on the File Name
  form_name = data_file.split("/").last.gsub('.csv','')
  # Slugify the formName to generate a slug
  form_slug = form_name.slugify
  # Check if form exists already
  if is_datastore
    puts "Checking if datastore (#{form_slug}) already axists"
    if requestce_sdk_space.find_datastore_form(form_slug).status == 404
      form_exists = false
    end
  else
    puts "Checking if kapp form (#{kapp_slug} / #{form_slug}) Already Exists"
    if requestce_sdk_space.find_form(kapp_slug, form_slug).status == 404
      form_exists = false
    end
  end

  count = %x{wc -l #{data_file}}.split.first.to_i
  puts "number of rows: #{count}"
  # Loop over each row in the CSV
  CSV.foreach(data_file, headers: true, col_sep: del).with_index do |row, i|
    # On the first row build up the fields based on headers and create the form.
    if(i == 0 && !form_exists)
      puts("Form (#{form_slug}) needs to be created")
      # Build up the form definition (without fields)
      form = build_form(form_name, form_slug)
      # Get Row Headers to build up form fields
      row.headers.each do |header|
        @fieldKey += 1
        form['pages'][0]['elements'].unshift(build_field_element(header))
      end
      # Create the form
      if is_datastore
        requestce_sdk_space.add_datastore_form(form).inspect
      else
        requestce_sdk_space.add_form(form)
      end
      # Reset the fieldKey for the next form
      @fieldKey = 0
    end
    # Create Row Submission
    values = Hash[ row.headers.collect { |h| [h, row[h]] } ]
    requestce_sdk_space.add_datastore_submission(form_slug, {"values" => values})
  end
end
