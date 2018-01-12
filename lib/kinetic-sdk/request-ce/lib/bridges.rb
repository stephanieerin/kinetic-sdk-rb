module KineticSdk
  class RequestCe

    # Add a Bridge
    #
    # @param body [Hash] optional properties associated to the Bridge
    #   - +name+
    #   - +status+
    #   - +url+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_bridge(body={}, headers=default_headers)
      info("Adding the \"#{body['name']}\" Bridge.")
      post("#{@api_url}/bridges", body, headers)
    end

    # Add a Bridge Model
    #
    # @param body [Hash] optional properties associated to the Bridge Model
    #   - +name+
    #   - +status+
    #   - +activeMappingName+
    #   - +attributes+
    #   - +mappings+
    #   - +qualifications+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_bridge_model(body={}, headers=default_headers)
      info("Adding the \"#{body['name']}\" Bridge Model and Mappings.")
      post("#{@api_url}/models", body, headers)
    end

    # Find a list of bridges
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_bridges(params={}, headers=default_headers)
      info("Find Bridges.")
      get("#{@api_url}/bridges", params, headers)
    end

    # Find a bridge
    #
    # @param name [String] name of the bridge
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_bridge(name, params={}, headers=default_headers)
      info("Finding the \"#{name}\" Bridge.")
      get("#{@api_url}/bridges/#{encode{name}}", params, headers)
    end

    # Update a bridge
    #
    # @param name [String] name of the bridge
    # @param body [Hash] properties of the bridge to update
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_bridge(name, body={}, headers=default_headers)
      info("Updating the \"#{name}\" Bridge.")
      put("#{@api_url}/bridges/#{encode(name)}", body, headers)
    end

  end
end
