Dir[File.join(File.dirname(File.expand_path(__FILE__)), "lib", "**", "*.rb")].each {|file| require file }

module KineticSdk

  # Filehub is a Ruby class that acts as a wrapper for the Kinetic FileHub REST API
  # without having to make explicit HTTP requests.
  #
  class Filehub

    # Include the KineticHttpUtils module
    include KineticSdk::Utils::KineticHttpUtils

    attr_reader :api_url, :username, :options, :password, :server, :version

    # Initalize the FileHub SDK with the web server URL and configuration user
    # credentials, along with any custom option values.
    #
    # @param opts [Hash] Kinetic FileHub properties
    # @option opts [String] :config_file optional - path to the YAML configuration file
    #
    #   * Ex: /opt/config/filehub-configuration1.yaml
    #
    # @option opts [String] :app_server_url the URL to the Kinetic Filehub web application.
    #
    #   * Ex: <http://192.168.0.1:8080/kinetic-filehub>
    #
    # @option opts [String] :username the username for the user
    # @option opts [String] :password the password for the user
    # @option opts [Hash<Symbol, Object>] :options ({}) optional settings
    #
    #   * :log_level (String) (_defaults to: off_) level of logging - off | info | debug | trace
    #   * :max_redirects (Fixnum) (_defaults to: 10_) maximum number of redirects to follow
    #   * :ssl_ca_file (String) full path to PEM certificate used to verify the server
    #   * :ssl_verify_mode (String) (_defaults to: none_) - none | peer
    #
    # Example: using a configuration file
    #
    #     KineticSdk::Filehub.new({
    #       config_file: "/opt/config1.yaml"
    #     })
    #
    # Example: using a properties hash
    #
    #     KineticSdk::Filehub.new({
    #       app_server_url: "http://localhost:8080/kinetic-filehub",
    #       username: "admin",
    #       password: "admin",
    #       options: {
    #         log_level: "debug",
    #         ssl_verify_mode: "peer",
    #         ssl_ca_file: "/usr/local/self_signing_ca.pem"
    #       }
    #     })
    #
    # If the +config_file+ option is present, it will be loaded first, and any additional
    # options will overwrite any values in the config file
    #
    def initialize(opts={})
      # initialize any variables
      options = {}

      # process the configuration file if it was provided
      unless opts[:config_file].nil?
        options.merge!(YAML::load opts[:config_file])
      end

      # process the configuration hash if it was provided
      options.merge!(opts)

      # process any individual options
      @options = options.delete(:options)
      @username = options[:username]
      @password = options[:password]
      @server = options[:app_server_url].chomp('/')
      @api_url = "#{@server}/app/api/v1"
      @version = 1
    end

  end
end
