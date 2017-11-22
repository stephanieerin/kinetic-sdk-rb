require 'slugify'

module KineticSdk
  class Task

    # Create a category
    #
    # @param category [Hash] Category properties
    #   - +name+ - name of the category
    #   - +handlers+ - array of handler definitionIds associated to the category
    #   - +policyRules+ - array of policy rule names associated to the category
    #   - +trees+ - array of tree (routine) definitionIds associated to the category
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_category(category, headers=default_headers)
      puts "Creating category \"#{category['name']}\""
      post("#{@api_url}/categories", category, headers)
    end

    # Delete a Category
    #
    # @param name [String] Category name
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_category(name, headers=header_basic_auth)
      puts "Deleting Category \"#{name}\""
      delete("#{@api_url}/categories/#{url_encode(name)}", headers)
    end

    # Delete all Categories
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_categories(headers=header_basic_auth)
      puts "Deleting all categories"
      find_categories(headers).each do |category_json|
        category = JSON.parse(category_json)
        delete_category(category['name'], headers)
      end
    end

    # Export a Category
    #
    # @param category [String|Hash] Category name, or hash of category properties
    #   - +name+ - name of the category
    #   - +handlers+ - array of handler definitionIds associated to the category
    #   - +policyRules+ - array of policy rule names associated to the category
    #   - +trees+ - array of tree (routine) definitionIds associated to the category
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_category(category, headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export a category." if @options[:export_directory].nil?
      if category.is_a? String
        response = retrieve_category(category, { "include" => "handlers,trees,policyRules" }, headers)
        category = JSON.parse(response)
      end
      puts "Exporting category \"#{category['name']}\" to #{@options[:export_directory]}."
      # Create the category directory if it doesn't yet exist
      category_dir = FileUtils::mkdir_p(File.join(@options[:export_directory], "categories"))
      category_file = File.join(category_dir, "#{category['name'].slugify}.json")

      # Just export the associated key values
      category['handlers'].collect! { |h| h['definitionId'] }.sort!
      category['trees'].collect! { |t| t['definitionId'] }.sort!
      category['policyRules'].collect! { |pr| pr['name'] }.sort!

      # write the file
      File.write(category_file, JSON.pretty_generate(category))
      puts "Exported category: #{category['name']} to #{category_file}"
    end

    # Export Categories
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_categories(headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export categories." if @options[:export_directory].nil?
      JSON.parse(find_categories({ "include" => "handlers,trees,policyRules" }))["categories"].each do |category|
        export_category(category)
      end
    end

    # Retrieve all categories
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_categories(params={}, headers=header_basic_auth)
      puts "Retrieving all categories"
      get("#{@api_url}/categories", params, headers)
    end

    # Retrieve a category
    #
    # @param name [String] name of the category
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_category(name, params={}, headers=header_basic_auth)
      puts "Retrieving Category \"#{name}\""
      get("#{@api_url}/categories/#{url_encode(name)}", params, headers)
    end

    # Update a category
    #
    # @param original_name [String] name of the category before updating
    # @param body [Hash] the updated property values
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    # 
    # Example
    #
    #     update_category("Foo", { "name" => "Bar" })
    #
    def update_category(original_name, body={}, headers=default_headers)
      puts "Updating Category \"#{original_name}\""
      put("#{@api_url}/categories/#{url_encode(original_name)}", body, headers)
    end


    # Add a handler to a category
    #
    # @param handler_id [String] the handler id to add
    # @param category_name [String] name of the category to associate the handler
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def add_handler_to_category(handler_id, category_name, headers=default_headers)
      body = { "definitionId" => handler_id }
      puts "Adding handler \"#{handler_id}\" to category \"#{category_name}\""
      post("#{@api_url}/categories/#{url_encode(category_name)}/handlers", body, headers)
    end

    # Remove a handler from a category
    #
    # @param handler_id [String] the handler id to remove
    # @param category_name [String] name of the category to remove the handler from
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def remove_handler_from_category(handler_id, category_name, headers=default_headers)
      puts "Removing handler \"#{handler_id}\" from category \"#{category_name}\""
      delete("#{@api_url}/categories/#{url_encode(category_name)}/handlers/#{url_encode(handler_id)}", headers)
    end

    # Add a global routine to a category
    #
    # @param routine_id [String] the global routine id to add
    # @param category_name [String] name of the category to associate the global routine
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def add_routine_to_category(routine_id, category_name, headers=default_headers)
      body = { "definitionId" => routine_id }
      puts "Adding routine \"#{routine_id}\" to category \"#{category_name}\""
      post("#{@api_url}/categories/#{url_encode(category_name)}/routines", body, headers)
    end

    # Add a global routine to a category
    #
    # @param routine_id [String] the global routine id to remove
    # @param category_name [String] name of the category to remove the global routine from
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def remove_routine_from_category(routine_id, category_name, headers=default_headers)
      puts "Removing routine \"#{routine_id}\" from category \"#{category_name}\""
      delete("#{@api_url}/categories/#{url_encode(category_name)}/routines/#{url_encode(routine_id)}", headers)
    end

    # Add a policy rule to a category
    #
    # @param policy_rule_type [String] the type of policy rule
    # @param policy_rule_name [String] the name of policy rule
    # @param category_name [String] name of the category to associate the policy rule
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def add_policy_rule_to_category(policy_rule_type, policy_rule_name, category_name, headers=default_headers)
      body = { "type" => policy_rule_type, "name" => policy_rule_name }
      puts "Adding policy rule \"#{policy_rule_type} - #{policy_rule_name}\" to category \"#{category_name}\""
      post("#{@api_url}/categories/#{url_encode(category_name)}/policyRules", body, headers)
    end

    # Remove a policy rule from a category
    #
    # @param policy_rule_type [String] the type of policy rule
    # @param policy_rule_name [String] the name of policy rule
    # @param category_name [String] name of the category to remove the policy rule from
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def remove_policy_rule_from_category(policy_rule_type, policy_rule_name, category_name, headers=default_headers)
      puts "Removing policy rule \"#{policy_rule_type} - #{policy_rule_name}\" from category \"#{category_name}\""
      delete("#{@api_url}/categories/#{url_encode(category_name)}/policyRules/#{url_encode(policy_rule_type)}/#{url_encode(policy_rule_name)}", headers)
    end

  end
end
