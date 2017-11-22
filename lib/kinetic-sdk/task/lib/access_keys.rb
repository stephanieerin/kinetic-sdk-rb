module KineticSdk
  class Task

    # Create an access key
    #
    # @param access_key [Hash] properties for the access key
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     create_access_key({
    #       "description" => "Description",
    #       "identifier" => "X54DLNU",
    #       "secret" => "xyz"
    #     })
    #
    # Example
    #
    #     create_access_key({
    #       "description" => "Description"
    #     })
    #
    # Example
    #
    #     create_access_key()
    #
    def create_access_key(access_key={}, headers=default_headers)
      puts "Adding access key " + (access_key.has_key?('identifier') ? access_key['identifier'] : "")
      post("#{@api_url}/access-keys", access_key, headers)
    end

    # Delete an access key
    #
    # @param identifier [String] access key identifier
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_source(identifier, headers=header_basic_auth)
      puts "Deleting access key \"#{identifier}\""
      delete("#{@api_url}/access-keys/#{url_encode(identifier)}", headers)
    end

    # Delete all access keys
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_access_keys(headers=header_basic_auth)
      puts "Deleting all access keys"
      JSON.parse(find_access_keys(headers))["accessKeys"].each do |access_key|
        delete("#{@api_url}/access_keys/#{url_encode(access_key['identifier'])}", headers)
      end
    end

    # Retrieve all access keys
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_access_keys(params={}, headers=header_basic_auth)
      puts "Retrieving all access keys"
      get("#{@api_url}/access-keys", params, headers)
    end

    # Retrieve an access key
    #
    # @param identifier [String] access key identifier
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_access_key(identifier, params={}, headers=default_headers)
      puts "Retrieving access key \"#{identifier}\""
      get("#{@api_url}/access-keys/#{url_encode(identifier)}", params, headers)
    end

    # Update an access key
    #
    # @param identifier [String] access key identifier
    # @param body [Hash] properties to update, all optional
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Exammple
    #
    #     update_identifier("X54DLNU", {
    #       "description": "Updated access key"
    #     })
    #
    def update_access_key(identifier, body={}, headers=default_headers)
      puts "Updating the \"#{identifier}\" access key"
      put("#{@api_url}/access-keys/#{url_encode(identifier)}", body, headers)
    end

  end
end
