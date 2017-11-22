require 'slugify'

module KineticSdk
  class Task

    # Create a group
    #
    # @param name [String] name of the group
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_group(name, headers=default_headers)
      puts "Creating group \"#{name}\""
      post("#{@api_url}/groups", { "name" => name }, headers)
    end

    # Delete a Group
    #
    # @param name [String] name of the group
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_group(name, headers=header_basic_auth)
      puts "Deleting Group \"#{name}\""
      delete("#{@api_url}/groups/#{url_encode(name)}", headers)
    end

    # Delete all Groups
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_groups(headers=header_basic_auth)
      puts "Deleting all groups"
      find_groups(headers).each do |group_json|
        group = JSON.parse(group_json)
        delete("#{@api_url}/groups/#{url_encode(group['name'])}", headers)
      end
    end

    # Export a Group
    #
    # @param group [String] name of the group
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_group(group, headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export a group." if @options[:export_directory].nil?
      if group.is_a? String
        response = retrieve_group(group, {}, headers)
        group = JSON.parse(response)
      end
      puts "Exporting group \"#{group['name']}\" to #{@options[:export_directory]}."
      # Create the groups directory if it doesn't yet exist
      group_dir = FileUtils::mkdir_p(File.join(@options[:export_directory], "groups"))
      group_file = File.join(group_dir, "#{group['name'].slugify}.json")
      # write the file
      responseObj = JSON.parse(get("#{@api_url}/groups/#{url_encode(group['name'])}", {}, headers))
      File.write(group_file, JSON.pretty_generate(responseObj))
      puts "Exported group: #{group['name']} to #{group_file}"
    end

    # Export Groups
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_groups(headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export groups." if @options[:export_directory].nil?
      JSON.parse(find_groups)["groups"].each do |group|
        export_group(group)
      end
    end

    # Retrieve all groups
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def find_groups(params={}, headers=header_basic_auth)
      puts "Retrieving all groups"
      get("#{@api_url}/groups", params, headers)
    end

    # Retrieve Group
    #
    # @param name [String] name of the group
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_group(name, params={}, headers=header_basic_auth)
      puts "Retrieving the #{name} group"
      get("#{@api_url}/groups/#{url_encode(name)}", params, headers)
    end

    # Add user to group
    #
    # @param login_id [String] login id of the user
    # @param group_name [String] name of the group
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def add_user_to_group(login_id, group_name, headers=default_headers)
      body = { "loginId" => login_id }
      puts "Adding user \"#{login_id}\" to group \"#{group_name}\""
      post("#{@api_url}/groups/#{url_encode(group_name)}/users", body, headers)
    end

    # Remove user from group
    #
    # @param login_id [String] login id of the user
    # @param group_name [String] name of the group
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def remove_user_from_group(login_id, group_name, headers=default_headers)
      puts "Removing user \"#{login_id}\" from group \"#{group_name}\""
      post("#{@api_url}/groups/#{url_encode(group_name)}/users/#{url_encode(login_id)}", headers)
    end

  end
end
