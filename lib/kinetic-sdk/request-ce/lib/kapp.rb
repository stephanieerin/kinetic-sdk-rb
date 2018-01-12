module KineticSdk
  class RequestCe

    # Add a Kapp
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
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_kapp(kapp_name, kapp_slug, properties={}, headers=default_headers)
      properties.merge!({
        "name" => kapp_name,
        "slug" => kapp_slug
      })
      info("Adding the \"#{kapp_name}\" Kapp.")
      post("#{@api_url}/kapps", properties, headers)
    end

    # Delete a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_kapp(kapp_slug, headers=default_headers)
      info("Deleting the \"#{kapp_slug}\" Kapp.")
      delete("#{@api_url}/kapps/#{kapp_slug}", headers)
    end

    # Exports a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def export_kapp(kapp_slug, headers=default_headers)
      info("Exporting the \"#{kapp_slug}\" Kapp.")
      get("#{@api_url}/kapps/#{kapp_slug}", { 'export' => true }, headers)
    end

    # Find Kapps
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_kapps(params={}, headers=default_headers)
      info("Finding Kapps.")
      get("#{@api_url}/kapps", params, headers)
    end

    # Find a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_kapp(kapp_slug, params={}, headers=default_headers)
      info("Finding Kapp \"#{kapp_slug}\"")
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
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_kapp(kapp_slug, properties={}, headers=default_headers)
      info("Updating the \"#{kapp_slug}\" Kapp.")
      put("#{@api_url}/kapps/#{kapp_slug}", properties, headers)
    end

  end
end
