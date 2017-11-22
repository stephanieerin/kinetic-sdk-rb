module KineticSdk
  class Task

    # Create a user
    #
    # @param user [Hash] user properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     create_user({
    #       "loginId" => "foo",
    #       "password" => "bar",
    #       "email" => "foo@bar.com"
    #     })
    #
    def create_user(user, headers=default_headers)
      puts "Creating user \"#{user['loginId']}\""
      post("#{@api_url}/users", user, headers)
    end

    # Delete a User
    #
    # @param login_id [String] login id of the user
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_user(login_id, headers=header_basic_auth)
      puts "Deleting User \"#{login_id}\""
      delete("#{@api_url}/users/#{url_encode(login_id)}", headers)
    end

    # Delete all Users
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_users(headers=header_basic_auth)
      puts "Deleting all users"
      find_users(headers).each do |user_json|
        user = JSON.parse(user_json)
        delete("#{@api_url}/users/#{url_encode(user['login_id'])}", headers)
      end
    end

    # Retrieve all users
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_users(params={}, headers=header_basic_auth)
      puts "Retrieving all users"
      get("#{@api_url}/users", params, headers)
    end

    # Update a user
    #
    # @param login_id [String] Login Id for the user
    # @param user [Hash] updated properties of the user
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     update_user({
    #       "loginId" => "foo",
    #       "password" => "bar",
    #       "email" => "foo@bar.com"
    #     })
    #
    def update_user(login_id, user, headers=default_headers)
      puts "Updating user \"#{login_id}\""
      put("#{@api_url}/users/#{url_encode(login_id)}", user, headers)
    end

  end
end
