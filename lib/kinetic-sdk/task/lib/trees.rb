require 'fileutils'
require 'slugify'

module KineticSdk
  class Task

    # Delete a tree.
    #
    # @param tree [String|Hash] either the tree title, or a hash consisting of component names
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     delete_tree("Kinetic Request CE :: Win a Car :: Complete")
    #
    # Example
    #
    #     delete_tree({
    #       "source_name" => "Kinetic Request CE",
    #       "group_name" => "Win a Car",
    #       "tree_name" => "Complete"
    #     })
    #
    def delete_tree(tree, headers=header_basic_auth)
      if tree.is_a? Hash
        title = "#{tree['source_name']} :: #{tree['group_name']} :: #{tree['tree_name']}"
      else
        title = "#{tree.to_s}"
      end
      puts "Deleting Tree \"#{title}\""
      delete("#{@api_url}/trees/#{url_encode(title)}", headers)
    end

    # Delete trees.
    #
    # If the source_name is provided, only trees that belong to the source
    # will be deleted, otherwise all trees will be deleted.
    #
    # @param source_name [String] the name of the source, or nil to delete all trees
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     delete_trees("Kinetic Request CE")
    #
    def delete_trees(source_name=nil, headers=header_basic_auth)
      if source_name.nil?
        puts "Deleting all trees"
        params = {}
      else
        puts "Deleting trees for Source \"#{source_name}\""
        params = { "source" => source_name }
      end

      JSON.parse(find_trees(params, headers))['trees'].each do |tree_json|
        puts "Deleting tree \"#{tree_json['title']}\""
        delete("#{@api_url}/trees/#{url_encode(tree_json['title'])}", headers)
      end
    end


    # Get a list of trees.
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     find_trees({ "source" => "Kinetic Request CE" })
    #
    # Example
    # 
    #     find_trees({ "include" => "details" })
    #
    # Example
    #
    #     find_trees({ "source" => "Kinetic Request CE", "include" => "details" })
    #
    def find_trees(params={}, headers=header_basic_auth)
      puts "Retrieving Trees"
      get("#{@api_url}/trees", params, headers)
    end

    # Get a list of routines.
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     find_routines({ "source" => "Kinetic Request CE" })
    #
    # Example
    #
    #     find_routines({ "include" => "details" })
    #
    # Example
    #
    #     find_routines({ "source" => "Kinetic Request CE", "include" => "details" })
    #
    def find_routines(params={}, headers=header_basic_auth)
      puts "Retrieving Routines"
      response = get("#{@api_url}/trees", params, headers)

      routines = []
      JSON.parse(response)["trees"].each do |tree|
        routines.push(tree) unless tree['definitionId'].nil?
      end
      # Return the result as a JSON string to be consistent with other methods
      { "trees" => routines }.to_json
    end

    # Import a tree
    #
    # If the tree already exists on the server, this will fail unless forced
    # to overwrite.
    #
    # The source named in the tree content must also exist on the server, or
    # the import will fail.
    #
    # @param tree [String] content from tree file
    # @param force_overwrite [Boolean] whether to overwrite a tree if it exists, default is false
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def import_tree(tree, force_overwrite=false, headers=header_basic_auth)
      body = { "content" => tree }
      puts "Importing Tree #{File.basename(tree)}"
      post_multipart("/trees?force=#{force_overwrite}", body, headers)
    end

    # Import a routine
    #
    # If the routine already exists on the server, this will fail unless
    # forced to overwrite.
    #
    # @param routine [String] content from routine file
    # @param force_overwrite [Boolean] whether to overwrite a routine if it exists, default is false
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def import_routine(routine, force_overwrite=false, headers=header_basic_auth)
      body = { "content" => routine }
      puts "Importing Routine #{File.basename(routine)}"
      post_multipart("/trees?force=#{force_overwrite}", body, headers)
    end

    # Retrieve a single tree by title (Source Name :: Group Name :: Tree Name)
    #
    # @param title [String] The tree title
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    # Example
    #
    #     retrieve_tree(
    #       "Kinetic Request CE :: Win a Car :: Complete",
    #       { "include" => "details" }
    #     )
    #
    def retrieve_tree(title, params={}, headers=header_basic_auth)
      puts "Retrieving the \"#{title}\" Tree"
      title = url_encode(title)
      get("#{@api_url}/trees/#{title}", params, headers)
    end

    # Export a single tree or routine
    #
    # @param title [String] the title of the tree or routine
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    #
    def export_tree(title, headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export a tree." if @options[:export_directory].nil?
      puts "Exporting tree \"#{title}\" to #{@options[:export_directory]}."
      # Get the tree
      response = retrieve_tree( title, { "include" => "export" })
      # Parse the response and export the tree
      tree = JSON.parse(response.body)

      # determine which directory to write the file to
      if tree['sourceGroup'] == "-"
        # Create the directory if it doesn't yet exist
        routine_dir = FileUtils::mkdir_p(File.join(@options[:export_directory], "routines"))
        tree_file = File.join(routine_dir, "#{tree['name'].slugify}.xml")
      else
        # Create the directory if it doesn't yet exist
        tree_dir = FileUtils::mkdir_p(File.join(@options[:export_directory], "trees", tree['sourceName'].slugify))
        tree_file = File.join(tree_dir, "#{tree['sourceName'].slugify}.#{tree['sourceGroup'].slugify}.#{tree['name'].slugify}.xml")
      end
      # write the file
      File.write(tree_file, tree['export'])
      puts "Exported #{tree['type']}: #{tree['title']} to #{tree_file}"
    end

    # Export all trees and local routines for a source, and global routines
    #
    # @param source_name [String] Name of the source to export trees and local routines
    #   - Leave blank or pass nil to export all trees and global routines
    #   - Pass "-" to export only global routines
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_trees(source_name=nil, headers=header_basic_auth)
      raise StandardError.new "An export directory must be defined to export trees." if @options[:export_directory].nil?
      if source_name.nil?
        puts "Exporting all trees and routines to #{@options[:export_directory]}."
        JSON.parse(find_sources)["sourceRoots"].each do |sourceRoot|
          export_trees(sourceRoot['name'])
        end
        return
      elsif source_name == "-"
        puts "Exporting global routines to #{@options[:export_directory]}."
      else
        puts "Exporting trees and routines for source \"#{source_name}\" to #{@options[:export_directory]}."
      end

      # Get all the trees and routines for the source
      response = find_trees({ "source" => source_name, "include" => "export" })
      # Parse the response and export each tree
      JSON.parse(response.body)["trees"].each do |tree|
        # determine which directory to write the file to
        if tree['sourceGroup'] == "-"
          # create the directory if it doesn't yet exist
          routine_dir = FileUtils::mkdir_p(File.join(@options[:export_directory], "routines"))
          tree_file = File.join(routine_dir, "#{tree['name'].slugify}.xml")
        else
          # create the directory if it doesn't yet exist
          tree_dir = FileUtils::mkdir_p(File.join(@options[:export_directory], "trees", source_name.slugify))
          tree_file = File.join(tree_dir, "#{source_name.slugify}.#{tree['sourceGroup'].slugify}.#{tree['name'].slugify}.xml")
        end
        # write the file
        File.write(tree_file, tree['export'])
        puts "Exported #{tree['type']}: #{tree['title']} to #{tree_file}"
      end
    end


    # Export all global routines
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_routines(headers=header_basic_auth)
      export_trees("-", headers)
    end

    # Create a new run of a tree
    #
    # @param title [String] title of the tree: Source Name, Group Name, Tree Name
    # @param body [Hash] properties to pass to the tree, what can be used/accepted
    #   depends on the source.
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def run_tree(title, body={}, headers=default_headers)
      puts "Running tree #{title}"
      parts = title.split(" :: ")
      raise StandardError.new "Title is invalid: #{title}" if parts.size != 3
      url = "#{@api_v1_url}/run-tree/#{url_encode(parts[0])}/#{url_encode(parts[1])}/#{url_encode(parts[2])}"
      post(url, body, headers)
    end

    # Update a tree
    #
    # @param title [String] title of the tree: Source Name, Group Name, Tree Name
    # @param body [Hash] properties to pass to the tree
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_tree(title, body={}, headers=default_headers)
      puts "Updating the \"#{title}\" Tree"
      put("#{@api_url}/trees/#{url_encode(title)}", body, headers)
    end

  end
end
