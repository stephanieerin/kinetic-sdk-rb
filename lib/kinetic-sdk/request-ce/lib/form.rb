module KineticSdk
  class RequestCe

    # Create a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_properties [Hash] form properties
    #   - +anonymous+
    #   - +customHeadContent+
    #   - +description+
    #   - +name+
    #   - +notes+
    #   - +slug+
    #   - +status+
    #   - +submissionLabelExpression+
    #   - +type+
    #   - +attributes+
    #   - +bridgedResources+
    #   - +pages+
    #   - +securityPolicies+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_form(kapp_slug, form_properties={}, headers=default_headers)
      puts "Creating the \"#{form_properties['name']}\" Form."
      post("#{@api_url}/kapps/#{kapp_slug}/forms", form_properties, headers)
    end

    # Delete a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_slug [String] slug of the form
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete_form(kapp_slug, form_slug, headers=default_headers)
      puts "Deleting the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp."
      delete("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}", headers)
    end

    # Export a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_slug [String] slug of the form
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def export_form(kapp_slug, form_slug, headers=default_headers)
      puts "Exporting the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp."
      get("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}", { 'export' => true }, headers)
    end

    # List Forms
    #
    # @param kapp_slug [String] slug of the Kapp the forms belongs to
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def list_forms(kapp_slug, params={}, headers=default_headers)
      puts "Listing Forms."
      get("#{@api_url}/kapps/#{kapp_slug}/forms", params, headers)
    end

    # Retrieve a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_slug [String] slug of the form
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_form(kapp_slug, form_slug, params={}, headers=default_headers)
      puts "Retrieving the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp."
      get("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}", params, headers)
    end

    # Update a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_slug [String] slug of the form
    # @param properties [Hash] form properties to update
    #   - +anonymous+
    #   - +customHeadContent+
    #   - +description+
    #   - +name+
    #   - +notes+
    #   - +slug+
    #   - +status+
    #   - +submissionLabelExpression+
    #   - +type+
    #   - +attributes+
    #   - +bridgedResources+
    #   - +pages+
    #   - +securityPolicies+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_form(kapp_slug, form_slug, properties={}, headers=default_headers)
      puts "Updating the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp."
      put("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}", properties, headers)
    end

  end
end
