Dir[File.join(File.dirname(File.expand_path(__FILE__)), "lib", "**", "*.rb")].each {|file| require file }

module KineticSdk

  # Bridgehub is a Ruby class that acts as a wrapper for the Kinetic BridgeHub REST API 
  # without having to make explicit HTTP requests.
  class Filehub

    # Include the Kinetic Http module
    include KineticSdk::Http

    attr_reader :api_url, :login, :options, :password, :server, :version

    # Initalize the FileHub SDK with the web server URL and configuration user
    # credentials, along with any custom option values.
    #
    # @param opts [Hash] Kinetic FileHub properties
    #   - +config_file+ - path to the YAML configuration file
    #     - Ex: /opt/config/filehub-configuration1.yaml
    #   - +app_server_url+ - the URL to the Kinetic FileHub web application.
    #     - Ex: http://192.168.0.1:8080/kinetic-filehub
    #   - +login+ - the login id for the user
    #   - +password+ - the password for the user
    #   - +options+ - optional settings
    #     - +log_level+ - info | debug (default: info)
    #
    # Example: configuration file
    #
    #     KineticSdk::Filehub.new({
    #       config_file: "/opt/config1.yaml"
    #     })
    #
    # Example: properties hash
    #
    #     KineticSdk::Filehub.new({
    #       app_server_url: "http://localhost:8080/kinetic-filehub",
    #       login: "admin",
    #       password: "admin",
    #       options: {
    #         log_level: "debug"
    #       }
    #     })
    #
    # If the +config_file+ option is present, it will be loaded first, and any additional 
    # options will overwrite any values in the config file
    #
    def initialize(opts={})
      # initialize any variables
      @options = {}

      # process the configuration file if it was provided
      unless opts[:config_file].nil?
        @options.merge!(YAML::load opts[:config_file])
      end

      # process any individual options
      @options.merge!(opts[:options]) if opts[:options].is_a? Hash
      @login = opts[:login]
      @password = opts[:password]
      @server = opts[:app_server_url]
      @api_url = "#{@server}/app/api/v1"
      @version = 1
    end

  end
end
