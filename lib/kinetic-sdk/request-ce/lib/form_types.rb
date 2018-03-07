module KineticSdk
  class RequestCe

    # Add a form type on a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp the form type belongs to
    # @param body [Hash] form type properties
    #   - +name+ - A descriptive name for the form type
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_form_type_on_kapp(kapp_slug, body, headers=default_headers)
      raise StandardError.new "Form Type properties is not valid, must be a Hash." unless body.is_a? Hash
      info("Adding Form Type \"#{body['name']}\" for \"#{kapp_slug}\" kapp")
      post("#{@api_url}/kapps/#{kapp_slug}/formTypes", body, headers)
    end

    # Delete a form type on a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp the form type belongs to
    # @param name [String] name of the form type
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_form_type(kapp_slug, name, headers=default_headers)
      info("Deleting form type \"#{name}\" from \"#{kapp_slug}\" kapp")
      delete("#{@api_url}/kapps/#{kapp_slug}/formTypes/#{encode(name)}", headers)
    end

    # Delete all form types on a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp the form types belongs to
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def delete_form_types_on_kapp(kapp_slug, headers=default_headers)
      (find_form_types_on_kapp(kapp_slug, {}, headers).content["formTypes"] || []).each do |form_type|
        delete_form_type(kapp_slug, form_type['name'], headers)
      end
    end

    # Retrieve a list of all form types for a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp the form types belongs to
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def find_form_types_on_kapp(kapp_slug, params={}, headers=default_headers)
      info("Finding Form Types for \"#{kapp_slug}\" kapp")
      get("#{@api_url}/kapps/#{kapp_slug}/formTypes", params, headers)
    end

  end
end
