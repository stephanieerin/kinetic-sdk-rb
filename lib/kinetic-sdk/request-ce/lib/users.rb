module KineticSdk
  class RequestCe

    # Add a user in a space.
    #
    # If the SDK was initialized as a System user, the space_slug property
    # must be provided in the user hash.
    #
    # If the SDK was initialized as a Space user, the space_slug property
    # is ignored.
    #
    # @param user [Hash] hash of user properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Example
    #
    #     add_user({
    #       "space_slug" => "bar",
    #       "username" => "foo",
    #       "password" => "bar",
    #       "displayName" => "Foo",
    #       "email" => "foo@bar.com",
    #       "enabled" => true,
    #       "preferredLocale" => "en_US",
    #       "spaceAdmin" => false
    #     })
    #
    def add_user(user, headers=default_headers)
      if !@space_slug.nil?
        info("Adding user \"#{user['username']}\" for Space \"#{@space_slug}\" as system user.")
        post("#{@api_url}/users", user, headers)
      elsif !user['space_slug'].nil?
        space_slug = user.delete('space_slug')
        info("Adding user \"#{user['username']}\" for Space \"#{space_slug}\".")
        post("#{@api_url}/spaces/#{space_slug}/users", user, headers)
      else
        raise StandardError.new "The space slug must be supplied to add the user."
      end
    end

    # Delete a user in a space.
    #
    # If the SDK was initialized as a System user, the space_slug property
    # must be provided in the user hash.
    #
    # If the SDK was initialized as a Space user, the space_slug property
    # is ignored.
    #
    # @param user [Hash] properties of the user
    #   - +space_slug+ - only used when initialized as a System user
    #   - +username+ - username of the user
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Example
    #
    #     delete_user({
    #       "username" => "user1"
    #     })
    #
    # Example
    #
    #     delete_user({
    #       "space_slug" => "foo",
    #       "username" => "user1"
    #     })
    #
    def delete_user(user, headers=default_headers)
      if !@space_slug.nil?
        info("Deleting user \"#{user['username']}\" for Space \"#{@space_slug}\" as system user.")
        delete("#{@api_url}/users/#{encode(user['username'])}", headers)
      elsif !user['space_slug'].nil?
        space_slug = user.delete('space_slug')
        info("Deleting user \"#{user['username']}\" for Space \"#{space_slug}\".")
        delete("#{@api_url}/spaces/#{space_slug}/users/#{encode(user['username'])}", headers)
      else
        raise StandardError.new "The space slug must be supplied to add the user."
      end
    end

    # Add an attribute value to the user, or update an attribute if it already exists
    #
    # @param username [String] username of the user
    # @param attribute_name [String] name of the attribute
    # @param attribute_value [String] value of the attribute
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_user_attribute(username, attribute_name, attribute_value, headers=default_headers)
      # first find the user
      response = find_user(username, { "include" => "attributes"}, headers)
      user = response.content["user"]
      attributes = user["attributes"]
      # either add or update the attribute value
      exists = false
      attributes.each do |attribute|
        # if the attribute already exists, update it
        if attribute["name"] == attribute_name
          attribute["values"] = attribute_value.is_a?(Array) ? attribute_value : [ attribute_value ]
          exists = true
        end
      end
      # add the attribute if it didn't exist
      attributes.push({
        "name" => attribute_name,
        "values" => attribute_value.is_a?(Array) ? attribute_value : [ attribute_value ]
        }) unless exists

      # set the updated attributes list
      body = { "attributes" => attributes }
      if exists
        info("Updating attribute \"#{attribute_name}\" on user \"#{username}\".")
      else
        info("Adding attribute \"#{attribute_name}\" to user \"#{username}\".")
      end
      # Update the user
      put("#{@api_url}/users/#{encode(username)}", body, headers)
    end

    # Adds an attribute value to an attribute.
    #
    # @param username [String] username of the user
    # @param attribute_name [String] name of the attribute
    # @param attribute_value [String] value of the attribute
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_user_attribute_value(username, attribute_name, attribute_value, headers=default_headers)
      # first find the user
      response = find_user(username, { "include" => "attributes"}, headers)
      user = response.content["user"]
      attributes = user["attributes"]
      # either add or update the attribute value
      exists = false
      attributes.each do |attribute|
        # if the attribute already exists, update it
        if attribute["name"] == attribute_name
          if attribute_value.is_a?(Array)
            attribute["values"].concat(attribute_value)
          else 
            attribute["values"] << attribute_value
          end
          attribute["values"].uniq!
          exists = true
        end
      end
      # add the attribute if it didn't exist
      attributes.push({
        "name" => attribute_name,
        "values" => attribute_value.is_a?(Array) ? attribute_value : [ attribute_value ]
        }) unless exists

      # set the updated attributes list
      body = { "attributes" => attributes }
      if exists
        info("Updating attribute \"#{attribute_name}\" on user \"#{username}\".")
      else
        info("Adding attribute \"#{attribute_name}\" to user \"#{username}\".")
      end
      # Update the user
      put("#{@api_url}/users/#{encode(username)}", body, headers)
    end

    # Find the user
    #
    # @param username [String] username of the user
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_user(username, params={}, headers=default_headers)
      info("Finding User \"#{username}\"")
      get("#{@api_url}/users/#{encode(username)}", params, headers)
    end

    # Update a user in a space.
    #
    # If the SDK was initialized as a System user, the space_slug property
    # must be provided in the user hash.
    #
    # If the SDK was initialized as a Space user, the space_slug property
    # is ignored.
    #
    # @param username [String] username of the user to update
    # @param user [Hash] user properties to update
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Example
    #
    #     update_user("xyz", {
    #       "space_slug" => "bar",
    #       "username" => "foo",
    #       "password" => "bar",
    #       "displayName" => "Foo",
    #       "email" => "foo@bar.com",
    #       "enabled" => true,
    #       "preferredLocale" => "en_US",
    #       "spaceAdmin" => false
    #     })
    #
    def update_user(username, user, headers=default_headers)
      if !@space_slug.nil?
        info("Updating user \"#{username}\" for Space \"#{@space_slug}\" as system user.")
        put("#{@api_url}/users/#{encode(username)}", user, headers)
      elsif !user['space_slug'].nil?
        space_slug = user.delete('space_slug')
        info("Updating user \"#{username}\" for Space \"#{space_slug}\".")
        put("#{@api_url}/spaces/#{space_slug}/users/#{encode(username)}", user, headers)
      else
        raise StandardError.new "The space slug must be supplied to update the user."
      end
    end

    # Generate Password Reset Token.
    #
    # @param username [String] username of the user
    # @param body [Hash] properties
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def generate_password_token(username, body={}, headers=default_headers)
      info("Generating PW Token for \"#{username}\"")
      post("#{@api_url}/users/#{encode(username)}/passwordResetToken", body, headers)
    end

    # Find the current user
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def me(params={}, headers=default_headers)
      info("Finding Me")
      get("#{@api_url}/me", params, headers)
    end

  end
end
