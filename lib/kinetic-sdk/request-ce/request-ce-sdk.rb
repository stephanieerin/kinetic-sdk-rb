Dir[File.join(File.dirname(File.expand_path(__FILE__)), "lib", "**", "*.rb")].each {|file| require file }

module KineticSdk

  # RequestCe is a Ruby class that acts as a wrapper for the Kinetic Request CE REST API 
  # without having to make explicit HTTP requests.
  class RequestCe

    # Include the KineticHttpUtils module
    include KineticSdk::Utils::KineticHttpUtils

    attr_reader :api_url, :username, :options, :password, :space_slug, :server, :version

    # Initalize the Request CE SDK with the web server URL, the space user
    # username and password, along with any custom option values.
    #
    # @param opts [Hash] Kinetic Request CE properties
    #   - +config_file+ - path to the YAML configuration file
    #     - Ex: /opt/config/request-ce-configuration1.yaml
    #   - +app_server_url+ - the URL to the Kinetic Request CE web application.
    #     - Ex: http://192.168.0.1:8080/kinetic
    #   - +space_slug+ - optional - the space slug if logging into a Space, otherwise nil to log into the system.
    #   - +username+ - the username for the user
    #   - +password+ - the password for the user
    #   - +options+ - optional settings
    #     - +log_level+ - off | info | debug | trace (default: off)
    #     - +max_redirects+ - Fixnum (default: 10)
    #     - +ssl_ca_file+ - full path to PEM certificate used to verify the server
    #     - +ssl_verify_mode+ - none | peer (default: none)
    #
    # Example: configuration file
    #
    #     KineticSdk::RequestCe.new({
    #       config_file: "/opt/config1.yaml"
    #     })
    #
    # Example: space user properties hash
    #
    #     KineticSdk::RequestCe.new({
    #       app_server_url: "http://localhost:8080/kinetic",
    #       space_slug: "foo",
    #       username: "space-user-1",
    #       password: "password",
    #       options: {
    #           log_level: "debug",
    #           ssl_verify_mode: "peer",
    #           ssl_ca_file: "/usr/local/self_signing_ca.pem"
    #       }
    #     })
    #
    # Example: system user properties hash
    #
    #     KineticSdk::RequestCe.new({
    #       app_server_url: "http://localhost:8080/kinetic",
    #       username: "admin",
    #       password: "password",
    #       options: {
    #           log_level: "debug",
    #           ssl_verify_mode: "peer",
    #           ssl_ca_file: "/usr/local/self_signing_ca.pem"
    #       }
    #     })
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
      @username = opts[:username]
      @password = opts[:password]
      @space_slug = opts[:space_slug]
      @server = opts[:app_server_url]
      @api_url = @server + (@space_slug.nil? ? "/app/api/v1" : "/#{@space_slug}/app/api/v1")
      @version = 1
    end

  end
end
