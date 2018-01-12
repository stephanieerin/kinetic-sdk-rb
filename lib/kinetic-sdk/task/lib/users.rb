module KineticSdk
  class Task

    # Add a user
    #
    # @param user [Hash] user properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Example
    #
    #     add_user({
    #       "loginId" => "foo",
    #       "password" => "bar",
    #       "email" => "foo@bar.com"
    #     })
    #
    def add_user(user, headers=default_headers)
      info("Add user \"#{user['loginId']}\"")
      post("#{@api_url}/users", user, headers)
    end

    # Delete a User
    #
    # @param login_id [String] login id of the user
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_user(login_id, headers=header_basic_auth)
      info("Deleting User \"#{login_id}\"")
      delete("#{@api_url}/users/#{encode(login_id)}", headers)
    end

    # Delete all Users
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_users(headers=header_basic_auth)
      info("Deleting all users")
      find_users(headers).content["users"].each do |user|
        delete("#{@api_url}/users/#{encode(user['login_id'])}", headers)
      end
    end

    # Find all users
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_users(params={}, headers=header_basic_auth)
      info("Finding all users")
      get("#{@api_url}/users", params, headers)
    end

    # Update a user
    #
    # @param login_id [String] Login Id for the user
    # @param user [Hash] updated properties of the user
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
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
      info("Updating user \"#{login_id}\"")
      put("#{@api_url}/users/#{encode(login_id)}", user, headers)
    end

  end
end
