module KineticSdk
  class RequestCe

    # Create a Kapp
    #
    # @param kapp_name [String] name of the Kapp
    # @param kapp_slug [String] slug of the Kapp
    # @param properties [Hash] optional properties associated to the Kapp
    #   - +afterLogoutPath+
    #   - +bundlePath+
    #   - +defaultFormDisplayPage+
    #   - +defaultFormConfirmationPage+
    #   - +defaultSubmissionLabelExpression+
    #   - +displayType+
    #   - +displayValue+
    #   - +loginPage+
    #   - +resetPasswordPage+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_kapp(kapp_name, kapp_slug, properties={}, headers=default_headers)
      properties.merge!({
        "name" => kapp_name,
        "slug" => kapp_slug
      })
      puts "Creating the \"#{kapp_name}\" Kapp."
      post("#{@api_url}/kapps", properties, headers)
    end

    # Delete a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_kapp(kapp_slug, headers=default_headers)
      puts "Deleting the \"#{kapp_slug}\" Kapp."
      delete("#{@api_url}/kapps/#{kapp_slug}", headers)
    end

    # Exports a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_kapp(kapp_slug, headers=default_headers)
      puts "Exporting the \"#{kapp_slug}\" Kapp."
      get("#{@api_url}/kapps/#{kapp_slug}", { 'export' => true }, headers)
    end

    # List Kapps
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def list_kapps(params={}, headers=default_headers)
      puts "Listing Kapps."
      get("#{@api_url}/kapps", params, headers)
    end

    # Retrieve a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_kapp(kapp_slug, params={}, headers=default_headers)
      puts "Retrieving Kapp \"#{kapp_slug}\""
      get("#{@api_url}/kapps/#{kapp_slug}", params, headers)
    end

    # Update a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param properties [Hash] optional properties associated to the Kapp
    #   - +afterLogoutPath+
    #   - +bundlePath+
    #   - +defaultFormDisplayPage+
    #   - +defaultFormConfirmationPage+
    #   - +defaultSubmissionLabelExpression+
    #   - +displayType+
    #   - +displayValue+
    #   - +loginPage+
    #   - +name+
    #   - +resetPasswordPage+
    #   - +slug+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_kapp(kapp_slug, properties={}, headers=default_headers)
      puts "Updating the \"#{kapp_slug}\" Kapp."
      put("#{@api_url}/kapps/#{kapp_slug}", properties, headers)
    end

  end
end
