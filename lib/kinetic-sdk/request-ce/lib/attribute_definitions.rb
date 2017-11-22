module KineticSdk
  class RequestCe

    # Create a new user attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_user_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      puts "Adding User attribute definition \"#{name}\" to the \"#{space_slug}\" space."
      # Create the user attribute definition
      post("#{@api_url}/userAttributeDefinitions", body, headers)
    end

    # Create a new user profile attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_user_profile_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      puts "Adding User attribute definition \"#{name}\" to the \"#{space_slug}\" space."
      # Create the user attribute definition
      post("#{@api_url}/userProfileAttributeDefinitions", body, headers)
    end

    # Create a new space attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_space_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      puts "Adding Space attribute definition \"#{name}\" to the \"#{space_slug}\" space."
      # Create the attribute definition
      post("#{@api_url}/spaceAttributeDefinitions", body, headers)
    end

    # Create a new category attribute definition.
    #
    # @param kapp_slug [String] slug of the kapp where the category exists
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_category_attribute_definition(kapp_slug, name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      puts "Adding Category attribute definition \"#{name}\" to the \"#{kapp_slug}\" kapp."
      # Create the attribute definition
      post("#{@api_url}/kapps/#{kapp_slug}/categoryAttributeDefinitions", body, headers)
    end

    # Create a new form attribute definition.
    #
    # @param kapp_slug [String] slug of the kapp where the form exists
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_form_attribute_definition(kapp_slug, name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      puts "Adding Form attribute definition \"#{name}\" to the \"#{kapp_slug}\" kapp."
      # Create the attribute definition
      post("#{@api_url}/kapps/#{kapp_slug}/formAttributeDefinitions", body, headers)
    end

    # Create a new kapp attribute definition.
    #
    # @param kapp_slug [String] slug of the kapp
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_kapp_attribute_definition(kapp_slug, name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      puts "Adding Kapp attribute definition \"#{name}\" to the \"#{kapp_slug}\" kapp."
      # Create the attribute definition
      post("#{@api_url}/kapps/#{kapp_slug}/kappAttributeDefinitions", body, headers)
    end

    # Create a new team attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_team_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      puts "Adding Team attribute definition \"#{name}\" to the \"#{space_slug}\" space."
      # Create the team attribute definition
      post("#{@api_url}/teamAttributeDefinitions", body, headers)
    end


  end
end
