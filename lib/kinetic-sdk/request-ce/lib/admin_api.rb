module KineticSdk
  class RequestCe

    # Create a Space
    #
    # @param name [String] name of the Space
    # @param slug [String] value that is used in URL routes to identity the Space
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_space(name, slug, headers=default_headers)
      payload = { "name" => name, "slug" => slug }
      puts "Creating Space \"#{name}\" with slug \"#{slug}\""
      post("#{@api_url}/spaces", payload, headers)
    end


    # Delete a Space
    #
    # @param slug [String] slug of the space
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_space(slug, headers=default_headers)
      puts "Deleting Space \"#{slug}\""
      delete("#{@api_url}/spaces/#{slug}", headers)
    end

    # Retrieve the space from the admin user
    #
    # @param slug [String] slug of the space
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_space_as_admin(slug, params={}, headers=default_headers)
      puts "Retrieving Space \"#{slug}\""
      get("#{@api_url}/spaces/#{slug}", params, headers)
    end

    # Update the space from the admin user
    #
    # @param slug [String] slug of the space
    # @param body [Hash] updated properties of the space
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_space_as_admin(slug, body, headers=default_headers)
      puts "Updating Space \"#{slug}\""
      put("#{@api_url}/spaces/#{slug}", body, headers)
    end

  end
end
