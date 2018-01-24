module KineticSdk
  class RequestCe

    # Add a new Space
    #
    # @param name [String] name of the Space
    # @param slug [String] value that is used in URL routes to identity the Space
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_space(name, slug, headers=default_headers)
      payload = { "name" => name, "slug" => slug }
      info("Creating Space \"#{name}\" with slug \"#{slug}\"")
      post("#{@api_url}/spaces", payload, headers)
    end


    # Delete a Space
    #
    # @param slug [String] slug of the space
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_space(slug, headers=default_headers)
      info("Deleting Space \"#{slug}\"")
      delete("#{@api_url}/spaces/#{slug}", headers)
    end

    # Find the space (System API)
    #
    # @param slug [String] slug of the space
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_space_in_system(slug, params={}, headers=default_headers)
      info("Retrieving Space \"#{slug}\"")
      get("#{@api_url}/spaces/#{slug}", params, headers)
    end

    # Update the space (System API)
    #
    # @param slug [String] slug of the space
    # @param body [Hash] updated properties of the space
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_space_in_system(slug, body, headers=default_headers)
      info("Updating Space \"#{slug}\"")
      put("#{@api_url}/spaces/#{slug}", body, headers)
    end

  end
end
