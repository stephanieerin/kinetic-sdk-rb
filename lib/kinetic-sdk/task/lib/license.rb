module KineticSdk
  class Task

    # Delete the license
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_license(headers=header_basic_auth)
      puts "Deleting the license"
      delete("#{@api_url}/config/license", {}, headers)
    end

    # Retrieve the license
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_license(params={}, headers=header_basic_auth)
      puts "Retrieving the license"
      get("#{@api_url}/config/license", params, headers)
    end

    # Update the license
    #
    # @param license_content [String] the content of the license file
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_license(license_content, headers=default_headers)
      body = { "licenseContent" => license_content }
      puts "Updating license"
      post("#{@api_url}/config/license", body, headers)
    end

    # Imports the license file
    #
    # @param license [String|File] Either the license file path (String), or the license file (File)
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def import_license(license, headers=default_headers)
      if license.is_a? File
        update_license(license.read, headers)
      else
        if File.exists? license
          update_license(File.read(license), headers)
        else
          puts "  * License file \"#{license}\" does not exist."
        end
      end
    end

  end
end
