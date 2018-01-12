module KineticSdk
  class Bridgehub

    # Add an Access Key for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param payload [Hash] properties for the access key
    #   - +description+
    #   - +id+
    #   - +secret+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_access_key(slug, payload, headers=default_headers)
      info("Adding Access Key for Bridge \"#{slug}\"")
      post("#{@api_url}/bridges/#{slug}/access-keys", payload, headers)
    end

    # Delete an Access Key for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param id [String] id (key) of the access key
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_access_key(slug, id, headers=default_headers)
      info("Deleting Access Key #{id} for Bridge \"#{slug}\"")
      delete("#{@api_url}/bridges/#{slug}/access-keys/#{id}", headers)
    end

    # Find Access Keys for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_access_keys(slug, params={}, headers=default_headers)
      info("Finding Access Keys for Bridge \"#{slug}\"")
      get("#{@api_url}/bridges/#{slug}/access-keys", params, headers)
    end

    # Find an Access Key for a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param id [String] id (key) of the access key
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_access_key(slug, id, params={}, headers=default_headers)
      info("Finding Access Key \"#{id}\" for Bridge \"#{slug}\"")
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
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_access_key(slug, id, payload, headers=default_headers)
      info("Updating Access Key \"#{id}\" for Bridge \"#{slug}\"")
      put("#{@api_url}/bridges/#{slug}/access-keys/#{id}", payload, headers)
    end

  end
end
