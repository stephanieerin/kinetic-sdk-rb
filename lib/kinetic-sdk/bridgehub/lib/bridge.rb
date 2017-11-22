module KineticSdk
  class Bridgehub

    # Create a Bridge
    #
    # @param payload [Hash] properties for the bridge
    #   - +adapterClass+
    #   - +name+
    #   - +slug+
    #   - +ipAddresses+
    #   - +useAccessKeys+
    #   - +properties+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_bridge(payload, headers=default_headers)
      puts "Creating Bridge \"#{payload['name']}\" with slug \"#{payload['slug']}\""
      post("#{@api_url}/bridges", payload, headers)
    end

    # Delete a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_bridge(slug, headers=default_headers)
      puts "Deleting Bridge \"#{slug}\""
      delete("#{@api_url}/bridges/#{slug}", headers)
    end

    # List Bridges
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_bridges(params={}, headers=default_headers)
      puts "Listing Bridges"
      get("#{@api_url}/bridges", params, headers)
    end

    # Retrieve a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_bridge(slug, params={}, headers=default_headers)
      puts "Retrieving Bridge \"#{slug}\""
      get("#{@api_url}/bridges/#{slug}", params, headers)
    end

    # Update a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param payload [Hash] properties for the bridge
    #   - +adapterClass+
    #   - +name+
    #   - +slug+
    #   - +ipAddresses+
    #   - +useAccessKeys+
    #   - +properties+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_bridge(slug, payload, headers=default_headers)
      puts "Updating Bridge \"#{slug}\""
      put("#{@api_url}/bridges/#{slug}", payload, headers)
    end

  end
end
