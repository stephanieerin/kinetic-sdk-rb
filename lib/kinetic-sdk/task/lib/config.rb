module KineticSdk
  class Task

    # Retrieve the database configuration
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_db(params={}, headers=header_basic_auth)
      puts "Retrieving database configuration"
      response = get("#{@api_url}/config/db", params, headers)
      response.body
    end


    # Retrieve the session configuration properties
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_session_configuration(params={}, headers=header_basic_auth)
      puts "Retrieving session timeout"
      response = get("#{@api_url}/config/session", params, headers)
      response.body
    end


    # Update the authentication settings
    #
    # @param settings [Hash] Settings for the authenticator
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     update_authentication({
    #       "authenticator" => "com.kineticdata.core.v1.authenticators.ProxyAuthenticator",
    #       "authenticationJsp" => "/WEB-INF/app/login.jsp",
    #       "properties" => {
    #         "Authenticator[Authentication Strategy]" => "Http Header",
    #         "Authenticator[Header Name]" => "X-Login",
    #         "Authenticator[Guest Access Enabled]" => "No"
    #       }
    #     })
    #
    def update_authentication(settings, headers=default_headers)
      puts "Updating the authentication properties"
      put("#{@api_url}/config/auth", settings, headers)
    end


    # Update the database configuration
    #
    # This assumes the database has already been created on the dbms.
    #
    # @param settings [Hash] Setting sfor the selected type of dbms
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     update_db({
    #       "hibernate.connection.driver_class" => "org.postgresql.Driver",
    #       "hibernate.connection.url" => "jdbc:postgresql://192.168.0.1:5432",
    #       "hibernate.connection.username" => "my-db-user",
    #       "hibernate.connection.password" => "my-db-password",
    #       "hibernate.dialect" => "com.kineticdata.task.adapters.dbms.KineticPostgreSQLDialect"
    #     })
    #
    def update_db(settings, headers=default_headers)
      puts "Updating the database properties"
      put("#{@api_url}/config/db", settings, headers)
    end


    # Update the engine settings
    #
    # @param settings [Hash] Settings for the selected type of dbms
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     update_engine({
    #       "Max Threads" => "1",
    #       "Sleep Delay" => "10",
    #       "Trigger Query" => "'Selection Criterion'=null"
    #     })
    #
    def update_engine(settings, headers=default_headers)
      puts "Updating the engine properties"
      put("#{@api_url}/config/engine", settings, headers)

      # start the task engine?
      if !settings['Sleep Delay'].nil? && settings['Sleep Delay'].to_i > 0
        puts "Starting the engine"
        start_engine
      end
    end


    # Update the identity store settings
    #
    # @param settings [Hash] Settings for the identity store
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     update_identity_store({
    #       "Identity Store" => "com.kineticdata.authentication.kineticcore.KineticCoreIdentityStore",
    #       "properties" => {
    #         "Kinetic Core Space Url" => "http://server:port/kinetic/space",
    #         "Group Attribute Name" => "Group",
    #         "Proxy Username" => "admin",
    #         "Proxy Password" => "admin"
    #       }
    #     })
    #
    def update_identity_store(settings, headers=default_headers)
      puts "Updating the identity store properties"
      put("#{@api_url}/config/identityStore", settings, headers)
    end


    # Update the web server and default configuration user settings
    #
    # @param settings [Hash] Settings for the web server and configurator user
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     update_properties({
    #       "Configurator Username" => "my-admin-user",
    #       "Configurator Password" => "my-admin-pass",
    #       "Log Level" => "DEBUG",
    #       "Log Size (MB)" => "20"
    #     })
    #
    # Example
    #
    #     update_properties({
    #       "Configurator Username" => "my-admin-user",
    #       "Configurator Password" => "my-admin-pass"
    #     })
    #
    def update_properties(settings, headers=default_headers)
      puts "Updating the web server properties"
      put("#{@api_url}/config/server", settings, headers)

      # reset the configuration user
      @config_user = {
        username: settings["Configurator Username"],
        password: settings["Configurator Password"]
      }
    end


    # Update the session configuration settings
    #
    # @param settings [Hash] Settings for the session configuration
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     update_session_configuration({
    #       "timeout" => "30"
    #     })
    #
    def update_session_configuration(settings, headers=default_headers)
      puts "Updating the session configuration settings"
      put("#{@api_url}/config/session", settings, headers)
    end

  end
end
