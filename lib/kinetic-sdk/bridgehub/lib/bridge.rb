module KineticSdk
  class Bridgehub

    # Add a Bridge
    #
    # @param payload [Hash] properties for the bridge
    #   - +adapterClass+
    #   - +name+
    #   - +slug+
    #   - +ipAddresses+
    #   - +useAccessKeys+
    #   - +properties+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_bridge(payload, headers=default_headers)
      info("Adding Bridge \"#{payload['name']}\" with slug \"#{payload['slug']}\"")
      post("#{@api_url}/bridges", payload, headers)
    end

    # Delete a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_bridge(slug, headers=default_headers)
      info("Deleting Bridge \"#{slug}\"")
      delete("#{@api_url}/bridges/#{slug}", headers)
    end

    # Find Bridges
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_bridges(params={}, headers=default_headers)
      info("Finding Bridges")
      get("#{@api_url}/bridges", params, headers)
    end

    # Find a Bridge
    #
    # @param slug [String] slug of the bridge
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_bridge(slug, params={}, headers=default_headers)
      info("Finding Bridge \"#{slug}\"")
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
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_bridge(slug, payload, headers=default_headers)
      info("Updating Bridge \"#{slug}\"")
      put("#{@api_url}/bridges/#{slug}", payload, headers)
    end

  end
end
