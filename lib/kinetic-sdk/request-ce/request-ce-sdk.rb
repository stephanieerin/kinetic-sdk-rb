Dir[File.join(File.dirname(File.expand_path(__FILE__)), "lib", "**", "*.rb")].each {|file| require file }

module KineticSdk

  # RequestCe is a Ruby class that acts as a wrapper for the Kinetic Request CE REST API
  # without having to make explicit HTTP requests.
  #
  class RequestCe

    # Include the KineticHttpUtils module
    include KineticSdk::Utils::KineticHttpUtils

    attr_reader :api_url, :username, :options, :password, :space_slug, :server, :version

    # Initalize the Request CE SDK with the web server URL, the space user
    # username and password, along with any custom option values.
    #
    # @param [Hash<Symbol, Object>] opts Kinetic Request CE properties
    # @option opts [String] :config_file optional - path to the YAML configuration file
    #
    #   * Ex: /opt/config/request-ce-configuration1.yaml
    #
    # @option opts [String] :app_server_url the URL to the Kinetic Request CE web application
    #
    #   * Must not be used when `:space_server_url` is also used.
    #   * If space_slug is provided, it will be appended to the URL as a path parameter
    #   * Ex: <http://192.168.0.1:8080/kinetic>
    #
    # @option opts [String] :space_server_url the URL to the Kinetic Request CE space
    #
    #   * Must not be used when `app_server_url` is used
    #   * Typically used when using a proxy server that supports space slugs as subdomains
    #   * Ex: <http://acme.server.io/kinetic> - space slug (`acme`) as subdomain
    #   * Ex: <http://localhost:8080/kinetic/acme> - same result as using `:app_server_url` and `:space_slug`
    #
    # @option opts [String] :space_slug the slug that identifies the Space
    #
    #   * Optional when `:app_server_url` is used
    #   * Required when `:space_server_url` is used
    #   * Required to log in to a Space
    #   * Must be nil to log in to the System
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
    # Example: space user properties hash with the space url
    #
    #     # Note: This example results in the same API endpoint as using:
    #     #
    #     #   app_server_url: https://myapp.io
    #
    #     KineticSdk::RequestCe.new({
    #       space_server_url: "https://myapp.io/foo",
    #       space_slug: "foo",
    #       username: "space-user-1",
    #       password: "password",
    #       options: {
    #         log_level: "info",
    #         max_redirects: 3
    #       }
    #     })
    #
    # Example: space user properties hash with the space url as a subdomain
    #
    #     # Note: This example requires a proxy server to rewrite the space slug
    #     #       as a request path parameter rather than a subdomain.
    #     #
    #     #   Ex: https://myapp.io/foo
    #
    #     KineticSdk::RequestCe.new({
    #       space_server_url: "https://foo.myapp.io",
    #       space_slug: "foo",
    #       username: "space-user-1",
    #       password: "password",
    #       options: {
    #         log_level: "info",
    #         max_redirects: 3
    #       }
    #     })
    #
    def initialize(opts={})
      options = {}

      # process the configuration file if it was provided
      unless opts[:config_file].nil?
        options.merge!(YAML::load opts[:config_file])
      end

      # process the configuration hash if it was provided
      options.merge!(opts)

      # allow either :app_server_url or :space_server_url, but not both
      if options[:app_server_url] && options[:space_server_url]
        raise StandardError.new "Expecting one of :app_server_url or :space_server_url, but not both."
      end

      # process any individual options
      @options = options.delete(:options) || {}
      @username = options[:username]
      @password = options[:password]
      @space_slug = options[:space_slug]
      if options[:app_server_url]
        @server = options[:app_server_url].chomp('/')
        @api_url = @server + (@space_slug.nil? ? "/app/api/v1" : "/#{@space_slug}/app/api/v1")
      else
        raise StandardError.new "The :space_slug option is required when using the :space_server_url option" if @space_slug.nil?
        @server = options[:space_server_url].chomp('/')
        @api_url = "#{@server}/app/api/v1"
      end
      @version = 1
    end

  end
end
