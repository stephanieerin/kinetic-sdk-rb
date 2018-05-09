module KineticSdk
  class RequestCe

    # Add a new user attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_user_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding User attribute definition \"#{name}\" to the \"#{space_slug}\" space.")
      # Create the user attribute definition
      post("#{@api_url}/userAttributeDefinitions", body, headers)
    end

    # Add a new user profile attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_user_profile_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding User attribute definition \"#{name}\" to the \"#{space_slug}\" space.")
      # Create the user attribute definition
      post("#{@api_url}/userProfileAttributeDefinitions", body, headers)
    end

    # Add a new space attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_space_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding Space attribute definition \"#{name}\" to the \"#{space_slug}\" space.")
      # Create the attribute definition
      post("#{@api_url}/spaceAttributeDefinitions", body, headers)
    end

    # Add a new datastore form attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_datastore_form_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding Datastore Form attribute definition \"#{name}\" to the \"#{space_slug}\" space.")
      # Create the attribute definition
      post("#{@api_url}/datastoreFormAttributeDefinitions", body, headers)
    end

    # Add a new category attribute definition.
    #
    # @param kapp_slug [String] slug of the kapp where the category exists
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_category_attribute_definition(kapp_slug, name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding Category attribute definition \"#{name}\" to the \"#{kapp_slug}\" kapp.")
      # Create the attribute definition
      post("#{@api_url}/kapps/#{kapp_slug}/categoryAttributeDefinitions", body, headers)
    end

    # Add a new form attribute definition.
    #
    # @param kapp_slug [String] slug of the kapp where the form exists
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_form_attribute_definition(kapp_slug, name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding Form attribute definition \"#{name}\" to the \"#{kapp_slug}\" kapp.")
      # Create the attribute definition
      post("#{@api_url}/kapps/#{kapp_slug}/formAttributeDefinitions", body, headers)
    end

    # Add a new kapp attribute definition.
    #
    # @param kapp_slug [String] slug of the kapp
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_kapp_attribute_definition(kapp_slug, name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding Kapp attribute definition \"#{name}\" to the \"#{kapp_slug}\" kapp.")
      # Create the attribute definition
      post("#{@api_url}/kapps/#{kapp_slug}/kappAttributeDefinitions", body, headers)
    end

    # Add a new team attribute definition.
    #
    # @param name [String] name of the attribute definition
    # @param description [String] description of the attribute definition
    # @param allows_multiple [Boolean] whether the attribute allows multiple values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_team_attribute_definition(name, description, allows_multiple, headers=default_headers)
      body = {
        "allowsMultiple" => allows_multiple,
        "description" => description,
        "name" => name
      }
      info("Adding Team attribute definition \"#{name}\" to the \"#{space_slug}\" space.")
      # Create the team attribute definition
      post("#{@api_url}/teamAttributeDefinitions", body, headers)
    end


  end
end
