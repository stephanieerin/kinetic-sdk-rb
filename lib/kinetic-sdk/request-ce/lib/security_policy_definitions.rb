module KineticSdk
  class RequestCe

    # Add a Space security policy definition
    #
    # @param body [Hash] properties of the security policy definition
    #   - +name+ - name of the security policy definition
    #   - +message+ - message for the security policy definition
    #   - +rule+ - rule for the security policy definition
    #   - +type+ - type of the security policy definition
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_space_security_policy_definition(body, headers=default_headers)
      info("Adding Space Security Policy Definition \"#{body['name']}\".")
      # Create the space security policy definition
      post("#{@api_url}/securityPolicyDefinitions", body, headers)
    end

    # Delete a Space security policy definition
    #
    # @param name [String] name of the security policy definition
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_space_security_policy_definition(name, headers=default_headers)
      info("Deleting Space Security Policy Definition \"#{name}\".")
      # Delete the space security policy definition
      delete("#{@api_url}/securityPolicyDefinitions/#{encode(name)}", headers)
    end

    # Delete all Space security policy definitions
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_space_security_policy_definitions(headers=default_headers)
      (find_space_security_policy_definitions({}, headers).content["securityPolicyDefinitions"] || []).each do |s|
        delete_space_security_policy_definition(s['name'], headers)
      end
    end

    # Find all Space security policy definitions
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_space_security_policy_definitions(params={}, headers=default_headers)
      info("Finding Space Security Policy Definitions.")
      get("#{@api_url}/securityPolicyDefinitions", params, headers)
    end

    # Find a single Space security policy definition
    #
    # @param name [String] name of the security policy definition
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_space_security_policy_definition(name, params={}, headers=default_headers)
      info("Finding Space Security Policy Definition \"#{name}\"")
      get("#{@api_url}/securityPolicyDefinitions/#{encode(name)}", params, headers)
    end
  
    # Update a Space security policy definition
    #
    # @param name [String] name of the security policy definition
    # @param body [Hash] properties of the security policy definition
    #   - +name+ - name of the security policy definition
    #   - +message+ - message for the security policy definition
    #   - +rule+ - rule for the security policy definition
    #   - +type+ - type of the security policy definition
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_space_security_policy_definition(name, body, headers=default_headers)
      info("Updating Space Security Policy Definition \"#{name}\"")
      put("#{@api_url}/securityPolicyDefinitions/#{encode(name)}", body, headers)
    end



    # Add a Kapp security policy definition
    #
    # @param kapp_slug [String] slug of the kapp
    # @param body [Hash] properties of the security policy definition
    #   - +name+ - name of the security policy definition
    #   - +message+ - message for the security policy definition
    #   - +rule+ - rule for the security policy definition
    #   - +type+ - type of the security policy definition
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_security_policy_definition(kapp_slug, body, headers=default_headers)
      info("Adding Security Policy Definition \"#{body['name']}\" to the \"#{kapp_slug}\" kapp.")
      # Create the kapp security policy definition
      post("#{@api_url}/kapps/#{kapp_slug}/securityPolicyDefinitions", body, headers)
    end

    # Delete a Kapp security policy definition
    #
    # @param kapp_slug [String] slug of the kapp
    # @param name [String] name of the security policy definition
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_security_policy_definition(kapp_slug, name, headers=default_headers)
      info("Deleting Security Policy Definition \"#{name}\" from the \"#{kapp_slug}\" kapp.")
      # Delete the kapp security policy definition
      delete("#{@api_url}/kapps/#{kapp_slug}/securityPolicyDefinitions/#{encode(name)}", headers)
    end

    # Delete all Kapp security policy definitions
    #
    # @param kapp_slug [String] slug of the kapp
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_security_policy_definitions(kapp_slug, headers=default_headers)
      (find_security_policy_definitions(kapp_slug, {}, headers).content["securityPolicyDefinitions"] || []).each do |s|
        delete_security_policy_definition(kapp_slug, s['name'], headers)
      end
    end

    # Find all Kapp security policy definitions
    #
    # @param kapp_slug [String] slug of the kapp
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_security_policy_definitions(kapp_slug, params={}, headers=default_headers)
      info("Listing Security Policy Definitions on the \"#{kapp_slug}\" kapp.")
      get("#{@api_url}/kapps/#{kapp_slug}/securityPolicyDefinitions", params, headers)
    end

    # Find a single Kapp security policy definition
    #
    # @param kapp_slug [String] slug of the kapp
    # @param name [String] name of the security policy definition
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_security_policy_definition(kapp_slug, name, params={}, headers=default_headers)
      info("Finding Security Policy Definition \"#{name}\" on the \"#{kapp_slug}\" kapp.")
      get("#{@api_url}/kapps/#{kapp_slug}/securityPolicyDefinitions/#{encode(name)}", params, headers)
    end

    # Update a Kapp security policy definition
    #
    # @param kapp_slug [String] slug of the kapp
    # @param name [String] name of the security policy definition
    # @param body [Hash] properties of the security policy definition
    #   - +name+ - name of the security policy definition
    #   - +message+ - message for the security policy definition
    #   - +rule+ - rule for the security policy definition
    #   - +type+ - type of the security policy definition
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_security_policy_definition(kapp_slug, name, body, headers=default_headers)
      info("Updating Security Policy Definition \"#{name}\" on the \"#{kapp_slug}\" kapp.")
      put("#{@api_url}/kapps/#{kapp_slug}/securityPolicyDefinitions/#{encode(name)}", body, headers)
    end

  end
end
