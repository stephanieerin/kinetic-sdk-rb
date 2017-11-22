module KineticSdk
  class Bridgehub

    # Create an Access Key for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param payload [Hash] properties for the access key
    #   - +description+
    #   - +id+
    #   - +secret+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_access_key(slug, payload, headers=default_headers)
      puts "Creating Access Key for Bridge \"#{slug}\""
      post("#{@api_url}/bridges/#{slug}/access-keys", payload, headers)
    end

    # Delete an Access Key for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param id [String] id (key) of the access key
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_access_key(slug, id, headers=default_headers)
      puts "Deleting Access Key #{id} for Bridge \"#{slug}\""
      delete("#{@api_url}/bridges/#{slug}/access-keys/#{id}", headers)
    end

    # List Access Keys for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_access_keys(slug, params={}, headers=default_headers)
      puts "Listing Access Keys for Bridge \"#{slug}\""
      get("#{@api_url}/bridges/#{slug}/access-keys", params, headers)
    end

    # Retrieve an Access Key for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param id [String] id (key) of the access key
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_access_key(slug, id, params={}, headers=default_headers)
      puts "Retrieving Access Key \"#{id}\" for Bridge \"#{slug}\""
      get("#{@api_url}/bridges/#{slug}/access-keys/#{id}", params, headers)
    end

    # Update a Bridge Access Key
    #
    # @param slug [String] slug of the bridge
    # @param id [String] id (key) of the access key
    # @param payload [Hash] properties for the access key
    #   - +description+
    #   - +secret+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_access_key(slug, id, payload, headers=default_headers)
      puts "Updating Access Key \"#{id}\" for Bridge \"#{slug}\""
      put("#{@api_url}/bridges/#{slug}/access-keys/#{id}", payload, headers)
    end

  end
end
