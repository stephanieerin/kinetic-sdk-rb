module KineticSdk
  class Filehub

    # Add a Filestore
    #
    # @param payload [Hash] properties for the bridge
    #   - +accessKeys+
    #   - +adapterClass+
    #   - +name+
    #   - +properties+
    #   - +slug+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_filestore(payload, headers=default_headers)
      info("Adding Filestore \"#{payload['name']}\" with slug \"#{payload['slug']}\"")
      post("#{@api_url}/filestores", payload, headers)
    end

    # Delete a Filestore
    #
    # @param slug [String] slug of the filestore
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_filestore(slug, headers=default_headers)
      info("Deleting Filestore \"#{slug}\"")
      delete("#{@api_url}/filestores/#{slug}", headers)
    end

    # Find Filestore
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_filestores(params={}, headers=default_headers)
      info("Find Filestores")
      get("#{@api_url}/filestores", params, headers)
    end

    # Find a Filestore
    #
    # @param slug [String] slug of the filestore
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_filestore(slug, params={}, headers=default_headers)
      info("Finding Filestore \"#{slug}\"")
      get("#{@api_url}/filestores/#{slug}", params, headers)
    end

    # Update a Filestore
    #
    # @param slug [String] slug of the filestore
    # @param payload [Hash] properties for the bridge
    #   - +accessKeys+
    #   - +adapterClass+
    #   - +name+
    #   - +properties+
    #   - +slug+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_filestore(slug, payload, headers=default_headers)
      info("Updating Filestore \"#{slug}\"")
      put("#{@api_url}/filestores/#{slug}", payload, headers)
    end

  end
end
