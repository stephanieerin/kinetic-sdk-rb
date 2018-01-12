module KineticSdk
  class RequestCe

    # Add an OAuth client
    #
    # @param options [Hash] oauth client properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_oauth_client(options, headers=default_headers)
      info("Adding the \"#{options['clientId']}\" OAuth client")
      post("#{@api_url}/oauthClients", options, headers)
    end

    # Find OAuth client
    #
    # @param client_id [String] - oauth client identifier
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_oauth_client(client_id, params={}, headers=default_headers)
      info("Finding OAuth Client \"#{client_id}\"")
      get("#{@api_url}/oauthClients/#{encode(client_id)}", params, headers)
    end

    # Update an OAuth client
    #
    # @param client_id [String] - oauth client identifier
    # @param options [Hash] oauth client properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_oauth_client(client_id, options, headers=default_headers)
      info("Updating the \"#{client_id}\" OAuth client")
      put("#{@api_url}/oauthClients/#{encode(client_id)}", options, headers)
    end

  end
end
