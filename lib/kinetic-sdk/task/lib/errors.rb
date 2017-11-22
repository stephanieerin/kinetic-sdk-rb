module KineticSdk
  class Task

    # Delete an Error
    #
    # @param id [Integer] id of the error
    # @param headers [Hash] headers to send with the request, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    # @since Task v4.3.0
    def delete_error(id, headers=header_basic_auth)
      puts "Deleting Error \"#{id}\""
      delete("#{@api_url}/errors/#{id}", headers)
    end

    # Resolve multiple errors with the same action and resolution notes.
    #
    # @param ids [Array<Integer>] Array of error ids to resolve
    # @param action [String] type of action to perform
    #   - +Cancel Branch+ - resolve the error and cancel the branch (connector error)
    #   - +Continue Branch+ - resolve the error and continue the branch (connector error)
    #   - +Do Nothing+ - resolve the error and do nothing more
    #   - +Retry+ - resolve the error and retry the connector that caused the error (connector error)
    #   - +Retry Task+ - resolve the error and retry the task that caused the error (node error)
    #   - +Skip Task+ - resolve the error and continue after the task that caused the error (node error)
    # @param resolution [String] resolution notes
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def resolve_errors(ids, action, resolution, headers=default_headers)
      puts "Resolving errors #{ids}"
      body = { "ids" => ids, "action" => action, "resolution" => resolution }
      post("#{@api_url}/errors/resolve", body, headers)
    end

    # Retrieve a list of errors.
    #
    # @param params [Hash] Query parameters that are added to the URL
    #   - +timeline+ - either "createdAt" or "updatedAt". Default: createdAt
    #   - +direction+ - DESC or ASC (default: DESC)
    #   - +start+ - 2017-07-27 or 2017-07-27T15:00:00.000Z
    #   - +end+ - 2017-07-27 or 2017-07-27T15:00:00.000Z
    #   - +source+ - name of the source
    #   - +sourceId+ - only if *source* is provided
    #   - +group+ - only if *source* is provided
    #   - +tree+ - only if *source* and *group* are provided
    #   - +nodeId+ - only if *source*, *group*, and *tree* are provided
    #   - +handlerId+
    #   - +runId+
    #   - +type+
    #   - +status+
    #   - +relatedItem1Id+
    #   - +relatedItem1Type+
    #   - +relatedItem2Id+
    #   - +relatedItem2Type+
    #   - +limit+
    #   - +offset+
    #   - +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_errors(params={}, headers=header_basic_auth)
      puts "Retrieving errors"
      get("#{@api_url}/errors", params, headers)
    end

    # Retrieve an Error
    #
    # @param id [Integer] id of the error
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_error(id, params={}, headers=header_basic_auth)
      puts "Retrieving error #{id}"
      get("#{@api_url}/errors/#{id}", params, headers)
    end

    # Retrieve Active Errors by Handler Id
    #
    # @param handler_id [String] handler identifier
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_active_errors_by_handler(handler_id, params={}, headers=header_basic_auth)
      puts "Retrieving active errors for handler #{handler_id}"
      params['handlerId'] = handler_id
      params['status'] = 'Active'
      find_errors(params, headers)
    end

    # Retrieve Active Errors by Source
    #
    # @param source_name [String] Source name
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_active_errors_by_source(source_name, params={}, headers=header_basic_auth)
      puts "Retrieving active errors for source \"#{source_name}\""
      params['source'] = source_name
      params['status'] = 'Active'
      find_errors(params, headers)
    end

    # Retrieve Active Errors by Source Group
    #
    # @param source_name [String] Source name
    # @param group [String] Source group
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_active_errors_by_source_group(source_name, group, params={}, headers=header_basic_auth)
      puts "Retrieving active errors for source group \"#{source_name} :: #{group}\""
      params['group'] = group
      params['source'] = source_name
      params['status'] = 'Active'
      find_errors(params, headers)
    end

    # Retrieve Active Errors by Tree Name
    #
    # @param source_name [String] Source name
    # @param group [String] Source group
    # @param tree_name [String] Tree name
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_active_errors_by_tree(source_name, group, tree_name, params={}, headers=header_basic_auth)
      puts "Retrieving active errors for tree \"#{source_name} :: #{group} :: #{tree_name}\""
      params['tree'] = tree_name
      params['group'] = group
      params['source'] = source_name
      params['status'] = 'Active'
      find_errors(params, headers)
    end

    # Retrieve Active Errors by Node
    #
    # @param source_name [String] Source name
    # @param group [String] Source group
    # @param tree_name [String] Tree name
    # @param node_id [String] Node id in the tree
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_active_errors_by_node(source_name, group, tree_name, node_id, params={}, headers=header_basic_auth)
      puts "Retrieving active errors for node \"#{source_name} :: #{group} :: #{tree_name} :: #{node_id}\""
      params['nodeId'] = node_id
      params['tree'] = tree_name
      params['group'] = group
      params['source'] = source_name
      params['status'] = 'Active'
      find_errors(params, headers)
    end

    # Retrieve Errors by Run Id
    #
    # @param run_id [Integer] Run id
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_errors_by_run(run_id, params={}, headers=header_basic_auth)
      puts "Retrieving active errors for run #{run_id}"
      params['runId'] = run_id
      find_errors(params, headers)
    end

  end
end
