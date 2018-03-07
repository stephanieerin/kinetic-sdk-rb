require 'slugify'

module KineticSdk
  class Task

    # Add a policy Rule
    #
    # @param policy [Hash] hash of properties for the new policy rule
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    # 
    # Example
    #
    #     add_policy_rule({
    #       "name" => "Foo",
    #       "type" => "Console Access | Category Access | API Access | System Default",
    #       "rule" => "...",
    #       "message" => "..."
    #     })
    #
    def add_policy_rule(policy, headers=default_headers)
      type = policy.delete("#{@api_url}type")
      info("Adding policy rule \"#{type} - #{policy['name']}\"")
      post("#{@api_url}/policyRules/#{encode(type)}", policy, headers)
    end

    # Delete a Policy Rule.
    #
    # @param policy [Hash] hash of policy type and name
    #   - +type+ - Policy Rule type ( API Access | Console Access | Category Access | System Default )
    #   - +name+ - Policy Rule name
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Example
    #
    #     delete_policy_rule({
    #       "type" => "API Access",
    #       "name" => "Company Network"
    #     })
    #
    def delete_policy_rule(policy, headers=header_basic_auth)
      info("Deleting policy rule \"#{policy['type']} - #{policy['name']}\"")
      delete("#{@api_url}/policyRules/#{encode(policy['type'])}/#{encode(policy['name'])}", headers)
    end

    # Delete all Policy Rules.
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_policy_rules(headers=header_basic_auth)
      info("Deleting all policy rules")
      (find_policy_rules(headers).content["policyRules"] || []).each do |policy_rule|
        delete_policy_rule({
          "type" => policy_rule['type'],
          "name" => policy_rule['name']
          }, headers)
      end
    end

    # Export a Policy Rule
    #
    # @param policy_rule [Hash] Policy Rule properties that must contain at least the name and type
    #   - +type+ - Policy Rule type ( API Access | Console Access | Category Access | System Default )
    #   - +name+ - Policy Rule name to export
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def export_policy_rule(policy_rule, headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export a policy rule." if @options[:export_directory].nil?
      info("Exporting policy rule \"policy_rule['type']\" : \"#{policy_rule['name']}\" to #{@options[:export_directory]}.")
      # Create the policy rules directory if it doesn't yet exist
      dir = FileUtils::mkdir_p(File.join(@options[:export_directory], "policyRules"))
      file = File.join(dir, "#{policy_rule['type'].slugify}-#{policy_rule['name'].slugify}.json")

      unless policy_rule.has_key?("consolePolicyRules")
        response = find_policy_rule(
          { "type" => policy_rule['type'], "name" => policy_rule['name'] },
          { "include" => "consolePolicyRules" },
          headers
        )
        if response.status != 200
          info("Failed to export policy rule: #{policy_rule['type']} - #{policy_rule['name']}: #{response.inspect}")
          policy_rule = nil
        else
          policy_rule = response.content
        end
      end

      unless policy_rule.nil?
        # write the file
        File.write(file, JSON.pretty_generate(policy_rule))
        info("Exported policy rule: #{policy_rule['type']} - #{policy_rule['name']} to #{file}")
      end
    end

    # Export Policy Rules
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def export_policy_rules(headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export policy rules." if @options[:export_directory].nil?
      response = find_policy_rules({"include" => "consolePolicyRules"}, headers)
      (response.content["policyRules"] || []).each do |policy_rule|
        export_policy_rule(policy_rule, headers)
      end
    end

    # Find Policy Rules.
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_policy_rules(params={}, headers=header_basic_auth)
      info("Finding Policy Rules")
      policy_rules = []
      response = nil
      ["API Access", "Category Access", "Console Access", "System Default"].each do |type|
        response = get("#{@api_url}/policyRules/#{encode(type)}", params, headers)
        policy_rules.concat(response.content["policyRules"])
      end
      final_content = { "policyRules" => policy_rules }
      response.content= final_content
      response.content_string= final_content.to_json
      response
    end


    # Find a policy rule
    #
    # @param policy_rule [Hash] Policy Rule properties that must contain at least the name and type
    #   - +type+ - Policy Rule type ( API Access | Console Access | Category Access | System Default )
    #   - +name+ - Policy Rule name to export
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Exammple
    #
    #     find_policy_rule({ "type" => "API Access", "name" => "Allow All"})
    #
    def find_policy_rule(policy_rule, params={}, headers=header_basic_auth)
      info("Finding the \"#{policy_rule['type']} - #{policy_rule['name']}\" Policy Rule")
      get("#{@api_url}/policyRules/#{encode(policy_rule['type'])}/#{encode(policy_rule['name'])}", params, headers)
    end


    # Update a Policy Rule
    #
    # @param policy_rule [Hash] Policy Rule properties that must contain the name and type
    #   - +type+ - Policy Rule type ( API Access | Console Access | Category Access | System Default )
    #   - +name+ - Policy Rule name to export
    # @param body [Hash] Policy rule properties to update
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    #
    # Exammple
    #
    #     update_policy_rule(
    #       { "type" => "API Access", "name" => "Allow All" },
    #       { "rule" => "false" }
    #     )
    #
    def update_policy_rule(policy_rule, body={}, headers=default_headers)
      info("Updating the \"#{policy_rule['type']} - #{policy_rule['name']}\" Policy Rule")
      put("#{@api_url}/policyRules/#{encode(policy_rule['type'])}/#{encode(policy_rule['name'])}", body, headers)
    end

  end
end
