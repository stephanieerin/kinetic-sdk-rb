module KineticSdk
  class RequestCe

    # Create an OAuth client
    #
    # @param options [Hash] oauth client properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_oauth_client(options, headers=default_headers)
      puts "Creating the \"#{options['clientId']}\" OAuth client"
      post("#{@api_url}/oauthClients", options, headers)
    end

    # Retrieve OAuth client
    #
    # @param client_id [String] - oauth client identifier
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_oauth_client(client_id, params={}, headers=default_headers)
      puts "Retrieving OAuth Client \"#{client_id}\""
      get("#{@api_url}/oauthClients/#{url_encode(client_id)}", params, headers)
    end

    # Update an OAuth client
    #
    # @param client_id [String] - oauth client identifier
    # @param options [Hash] oauth client properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_oauth_client(client_id, options, headers=default_headers)
      puts "Updating the \"#{client_id}\" OAuth client"
      put("#{@api_url}/oauthClients/#{url_encode(client_id)}", options, headers)
    end

  end
end
