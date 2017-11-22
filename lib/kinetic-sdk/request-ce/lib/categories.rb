module KineticSdk
  class RequestCe

    # Create a category on a Kapp
    #
    # @param kapp_slug [String] slug of the Kapp the category belongs to
    # @param body [Hash] category properties
    #   - +name+ - A descriptive name for the category
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_category_on_kapp(kapp_slug, body, headers=default_headers)
      raise StandardError.new "Category properties is not valid, must be a Hash." unless body.is_a? Hash
      puts "Creating Category \"#{body['name']}\" for \"#{kapp_slug}\" kapp"
      post("#{@api_url}/kapps/#{kapp_slug}/categories", body, headers)
    end

    # Create a categorization on a form
    #
    # @param kapp_slug [String] slug of the Kapp the category belongs to
    # @param body [Hash] category properties
    #   - +name+ - A descriptive name for the category
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_categorization_on_form(kapp_slug, body, headers=default_headers)
      raise StandardError.new "Category properties is not valid, must be a Hash." unless body.is_a? Hash
      puts "Creating Category \"#{body['name']}\" for \"#{kapp_slug}\" kapp"
      post("#{@api_url}/kapps/#{kapp_slug}/categorizations", body, headers)
    end

  end
end
