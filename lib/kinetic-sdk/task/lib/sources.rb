module KineticSdk
  class Task

    # Create a source
    #
    # @param source [Hash] Source properties
    #   - +name+ - name of the source
    #   - +status+ - initial status of the source (Active | Inactive)
    #   - +type+ - name of one of the source consumers registered in the task engine
    #   - +properties+ - hash of properties specific to the source consumer
    #   - +policyRules+ - array of policy rules to associate with the source
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     create_source({
    #       "name" => "Source Name",
    #       "status" => "Active",
    #       "type" => "Kinetic Request CE",
    #       "properties" => {
    #         "Space Slug" => "foo",
    #         "Web Server" => "http://localhost:8080/kinetic",
    #         "Proxy Username" => "integration-user",
    #         "Proxy Password" => "integration-password"
    #       },
    #       "policyRules" => []
    #     })
    #
    def create_source(source, headers=default_headers)
      name = source['name']
      puts "Adding the #{name} source"
      post("#{@api_url}/sources", source, headers)
    end

    # Delete a Source
    #
    # @param name [String] name of the source
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_source(name, headers=header_basic_auth)
      puts "Deleting Source \"#{name}\""
      delete("#{@api_url}/sources/#{url_encode(name)}", headers)
    end

    # Delete all Sources
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_sources(headers=header_basic_auth)
      puts "Deleting all sources"
      find_sources(headers).each do |source_json|
        source = JSON.parse(source_json)
        delete("#{@api_url}/sources/#{url_encode(source['name'])}", headers)
      end
    end

    # Retrieve all sources
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_sources(params={}, headers=header_basic_auth)
      puts "Retrieving all sources"
      get("#{@api_url}/sources", params, headers)
    end

    # Retrieve a source
    #
    # @param name [String] name of the source
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_source(name, params={}, headers=header_basic_auth)
      puts "Retrieving source named \"#{name}\""
      get("#{@api_url}/sources/#{url_encode(name)}", params, headers)
    end

    # Update a source
    #
    # @param source [Hash] hash of existing source properties that must contain 'name'
    #   - +name+ - name of the source
    # @param body [Hash] - source properties to update
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Exammple
    #
    #     update_source(
    #       { "name" => "Kinetic Request CE" },
    #       {
    #         "name": "Possible New Source Name",
    #         "status": "Active|Unconfigured",
    #         "type": "Adhoc|...",
    #         "properties": {},
    #         "policyRules": [
    #           { "type": "API Access", "name": "Super User" },
    #           { "type": "API Access", "name": "Info User" },
    #           { "type": "Console Access", "name": "Super User" }
    #         ]
    #       }
    #     )
    #
    def update_source(source, body={}, headers=default_headers)
      puts "Updating the \"#{source['name']}\" Source"
      put("#{@api_url}/sources/#{url_encode(source['name'])}", body, headers)
    end

    # Add policy rule to source
    #
    # @param policy_rule_type [String] the type of policy rule
    # @param policy_rule_name [String] the name of the policy rule
    # @param source_name [String] name of the source to add the policy rule to
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def add_policy_rule_to_source(policy_rule_type, policy_rule_name, source_name, headers=default_headers)
      body = { "type" => policy_rule_type, "name" => policy_rule_name }
      puts "Adding policy rule \"#{policy_rule_type} - #{policy_rule_name}\" to source \"#{source_name}\""
      post("#{@api_url}/sources/#{url_encode(source_name)}/policyRules", body, headers)
    end

    # Remove policy rule from source
    #
    # @param policy_rule_type [String] the type of policy rule
    # @param policy_rule_name [String] the name of the policy rule
    # @param source_name [String] name of the source to add the policy rule to
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def remove_policy_rule_from_source(policy_rule_type, policy_rule_name, source_name, headers=default_headers)
      puts "Removing policy rule \"#{policy_rule_type} - #{policy_rule_name}\" from source \"#{source_name}\""
      delete("#{@api_url}/sources/#{url_encode(source_name)}/policyRules/#{url_encode(policy_rule_type)}/#{url_encode(policy_rule_name)}", headers)
    end

  end
end
