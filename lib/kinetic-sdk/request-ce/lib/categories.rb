module KineticSdk
  class RequestCe

    # Add a category on a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp the category belongs to
    # @param body [Hash] category properties
    #   - +name+ - A descriptive name for the category
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_category_on_kapp(kapp_slug, body, headers=default_headers)
      raise StandardError.new "Category properties is not valid, must be a Hash." unless body.is_a? Hash
      info("Adding Category \"#{body['name']}\" for \"#{kapp_slug}\" kapp")
      post("#{@api_url}/kapps/#{kapp_slug}/categories", body, headers)
    end

    # Add a categorization on a form
    #
    # @param kapp_slug [String] slug of the Kapp the category belongs to
    # @param body [Hash] categorization properties
    #   - +category+ - A hash of properties for the category
    #   - +category/slug+ - The slug of the category to apply to the form
    #   - +form+ - A hash of properties for the form
    #   - +form/slug+ - The slug of the form to apply the category
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def add_categorization_on_form(kapp_slug, body, headers=default_headers)
      raise StandardError.new "Category properties is not valid, must be a Hash." unless body.is_a? Hash
      info("Adding Categorization for \"#{kapp_slug}\" kapp")
      post("#{@api_url}/kapps/#{kapp_slug}/categorizations", body, headers)
    end

  end
end
