module KineticSdk
  class RequestCe

    # Create a Bridge
    #
    # @param body [Hash] optional properties associated to the Bridge
    #   - +name+
    #   - +status+
    #   - +url+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_bridge(body={}, headers=default_headers)
      puts "Creating the \"#{body['name']}\" Bridge."
      post("#{@api_url}/bridges", body, headers)
    end

    # Create a Bridge Model
    #
    # @param body [Hash] optional properties associated to the Bridge Model
    #   - +name+
    #   - +status+
    #   - +activeMappingName+
    #   - +attributes+
    #   - +mappings+
    #   - +qualifications+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_bridge_model(body={}, headers=default_headers)
      puts "Creating the \"#{body['name']}\" Bridge Model and Mappings."
      post("#{@api_url}/models", body, headers)
    end

    # Retrieve a list of bridges
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def list_bridges(params={}, headers=default_headers)
      puts "List Bridges."
      get("#{@api_url}/bridges", params, headers)
    end

    # Retrieve a bridge
    #
    # @param name [String] name of the bridge
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_bridge(name, params={}, headers=default_headers)
      puts "Retrieving the \"#{name}\" Bridge."
      get("#{@api_url}/bridges/#{url_encode{name}}", params, headers)
    end

    # Update a bridge
    #
    # @param name [String] name of the bridge
    # @param body [Hash] properties of the bridge to update
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_bridge(name, body={}, headers=default_headers)
      puts "Updating the \"#{name}\" Bridge."
      put("#{@api_url}/bridges/#{url_encode(name)}", body, headers)
    end

  end
end
