module KineticSdk
  class Filehub

    # Create a Filestore
    #
    # @param payload [Hash] properties for the bridge
    #   - +accessKeys+
    #   - +adapterClass+
    #   - +name+
    #   - +properties+
    #   - +slug+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_filestore(payload, headers=default_headers)
      puts "Creating Filestore \"#{payload['name']}\" with slug \"#{payload['slug']}\""
      post("#{@api_url}/filestores", payload, headers)
    end

    # Delete a Filestore
    #
    # @param slug [String] slug of the filestore
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_filestore(slug, headers=default_headers)
      puts "Deleting Filestore \"#{slug}\""
      delete("#{@api_url}/filestores/#{slug}", headers)
    end

    # List Filestore
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_filestores(params={}, headers=default_headers)
      puts "Listing Filestores"
      get("#{@api_url}/filestores", params, headers)
    end

    # Retrieve a Filestore
    #
    # @param slug [String] slug of the filestore
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_filestore(slug, params={}, headers=default_headers)
      puts "Retrieving Filestore \"#{slug}\""
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
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_filestore(slug, payload, headers=default_headers)
      puts "Updating Filestore \"#{slug}\""
      put("#{@api_url}/filestores/#{slug}", payload, headers)
    end

  end
end
