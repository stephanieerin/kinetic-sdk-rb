module KineticSdk
  class Task

    # Delete the license
    #
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_license(headers=header_basic_auth)
      info("Deleting the license")
      delete("#{@api_url}/config/license", {}, headers)
    end

    # Find the license
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_license(params={}, headers=header_basic_auth)
      info("Finding the license")
      get("#{@api_url}/config/license", params, headers)
    end

    # Update the license
    #
    # @param license_content [String] the content of the license file
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_license(license_content, headers=default_headers)
      body = { "licenseContent" => license_content }
      info("Updating license")
      post("#{@api_url}/config/license", body, headers)
    end

    # Imports the license file
    #
    # @param license [String|File] Either the license file path (String), or the license file (File)
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def import_license(license, headers=default_headers)
      if license.is_a? File
        update_license(license.read, headers)
      else
        if File.exists? license
          update_license(File.read(license), headers)
        else
          info("  * License file \"#{license}\" does not exist.")
        end
      end
    end

  end
end
