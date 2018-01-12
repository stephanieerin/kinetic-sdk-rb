module KineticSdk
  class RequestCe

    # Add a Form
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
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_form(kapp_slug, form_properties={}, headers=default_headers)
      info("Adding the \"#{form_properties['name']}\" Form.")
      post("#{@api_url}/kapps/#{kapp_slug}/forms", form_properties, headers)
    end

    # Delete a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_slug [String] slug of the form
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_form(kapp_slug, form_slug, headers=default_headers)
      info("Deleting the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp.")
      delete("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}", headers)
    end

    # Export a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_slug [String] slug of the form
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def export_form(kapp_slug, form_slug, headers=default_headers)
      info("Exporting the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp.")
      get("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}", { 'export' => true }, headers)
    end

    # Find Forms
    #
    # @param kapp_slug [String] slug of the Kapp the forms belongs to
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_forms(kapp_slug, params={}, headers=default_headers)
      info("Finding Forms.")
      get("#{@api_url}/kapps/#{kapp_slug}/forms", params, headers)
    end

    # Find a Form
    #
    # @param kapp_slug [String] slug of the Kapp the form belongs to
    # @param form_slug [String] slug of the form
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_form(kapp_slug, form_slug, params={}, headers=default_headers)
      info("Finding the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp.")
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
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def update_form(kapp_slug, form_slug, properties={}, headers=default_headers)
      info("Updating the \"#{form_slug}\" Form in the \"#{kapp_slug}\" Kapp.")
      put("#{@api_url}/kapps/#{kapp_slug}/forms/#{form_slug}", properties, headers)
    end

  end
end
