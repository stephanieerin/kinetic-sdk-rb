module KineticSdk
  class Task

    # Add an access key
    #
    # @param access_key [Hash] properties for the access key
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Example
    #
    #     add_access_key({
    #       "description" => "Description",
    #       "identifier" => "X54DLNU",
    #       "secret" => "xyz"
    #     })
    #
    # Example
    #
    #     add_access_key({
    #       "description" => "Description"
    #     })
    #
    # Example
    #
    #     add_access_key()
    #
    def add_access_key(access_key={}, headers=default_headers)
      info("Adding access key " + (access_key.has_key?('identifier') ? access_key['identifier'] : ""))
      post("#{@api_url}/access-keys", access_key, headers)
    end

    # Delete an access key
    #
    # @param identifier [String] access key identifier
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_access_key(identifier, headers=header_basic_auth)
      info("Deleting access key \"#{identifier}\"")
      delete("#{@api_url}/access-keys/#{encode(identifier)}", headers)
    end

    # Delete all access keys
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_access_keys(headers=header_basic_auth)
      info("Deleting all access keys")
      (find_access_keys(headers).content["accessKeys"] || []).each do |access_key|
        delete("#{@api_url}/access_keys/#{encode(access_key['identifier'])}", headers)
      end
    end

    # Find all access keys
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_access_keys(params={}, headers=header_basic_auth)
      info("Finding all access keys")
      get("#{@api_url}/access-keys", params, headers)
    end

    # Find an access key
    #
    # @param identifier [String] access key identifier
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_access_key(identifier, params={}, headers=default_headers)
      info("Finding access key \"#{identifier}\"")
      get("#{@api_url}/access-keys/#{encode(identifier)}", params, headers)
    end

    # Update an access key
    #
    # @param identifier [String] access key identifier
    # @param body [Hash] properties to update, all optional
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Exammple
    #
    #     update_identifier("X54DLNU", {
    #       "description": "Updated access key"
    #     })
    #
    def update_access_key(identifier, body={}, headers=default_headers)
      info("Updating the \"#{identifier}\" access key")
      put("#{@api_url}/access-keys/#{encode(identifier)}", body, headers)
    end

  end
end
