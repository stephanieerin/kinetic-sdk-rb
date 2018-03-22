Dir[File.join(File.dirname(File.expand_path(__FILE__)), "lib", "**", "*.rb")].each {|file| require file }

module KineticSdk
  
  # Task is a Ruby class that acts as a wrapper for the Kinetic Task REST API 
  # without having to make explicit HTTP requests.
  class Task

    # Include the KineticHttpUtils module
    include KineticSdk::Utils::KineticHttpUtils

    attr_reader :api_url, :api_v1_url, :config_user, :options, :server, :version, :username, :password

    # Initalize the Task SDK with the web server URL and user credentials, 
    # along with any custom option values.
    #
    # @param opts [Hash] Kinetic Task properties
    #   - +config_file+ - path to the YAML configuration file
    #     - Ex: /opt/config/task-configuration1.yaml
    #   - +app_server_url+ - the URL to the Kinetic Task web application.
    #     - Ex: http://192.168.0.1:8080/kinetic-task
    #   - +username+ - the username for the user
    #   - +password+ - the password for the user
    #   - +options+ - optional settings
    #     - +log_level+ - off | info | debug | trace (default: off)
    #     - +max_redirects+ - Fixnum (default: 10)
    #
    # Example: configuration file
    #
    #     KineticSdk::Task.new({
    #       config_file: "/opt/config1.yaml"
    #     })
    #
    # Example: properties hash
    #
    #     KineticSdk::Task.new({
    #       app_server_url: "http://localhost:8080/kinetic-task",
    #       username: "admin",
    #       password: "admin",
    #       options: {
    #         log_level: "debug",
    #         export_directory: "/opt/exports/task-server-a"
    #       }
    #     })
    #
    # If the +config_file+ option is present, it will be loaded first, and any additional 
    # options will overwrite any values in the config file
    #
    def initialize(opts)
      # initialize any variables
      @options = {}
      @config_user = {}
      @server = nil

      # process the configuration file if it was provided
      unless opts[:config_file].nil?
        @options.merge!(YAML::load opts[:config_file])
      end

      # process any individual options
      @options.merge!(opts[:options]) if opts[:options].is_a? Hash
      @config_user[:username] = opts[:username]
      @config_user[:password] = opts[:password]
      @server = opts[:app_server_url]
      @username = @config_user[:username]
      @password = @config_user[:password]

      # TODO: Better separation of APIv1 and APIv2
      @api_v1_url = "#{@server}/app/api/v1"
      @api_v2_url = "#{@server}/app/api/v2"

      # set any constants or calculated values
      @api_url = @api_v2_url
      @version = 2
    end

  end
end
