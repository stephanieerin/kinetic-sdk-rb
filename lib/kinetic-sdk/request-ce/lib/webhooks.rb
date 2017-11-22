module KineticSdk
  class RequestCe

    # Create form webhook
    #
    # @param kapp_slug [String] slug of the Kapp the form webhook belongs to
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - Created | Deleted | Updated
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_form_webhook(kapp_slug, webhook_properties, headers=default_headers)
      raise StandardError.new "Webhook properties is not valid, must be a Hash." unless webhook_properties.is_a? Hash
      payload = { "type" => "Form" }.merge(webhook_properties)
      create_webhook_on_kapp(kapp_slug, payload, headers)
    end

    # Create space webhook
    #
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - Login Failure
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_space_webhook(webhook_properties, headers=default_headers)
      raise StandardError.new "Webhook properties is not valid, must be a Hash." unless webhook_properties.is_a? Hash
      payload = { "type" => "Space" }.merge(webhook_properties)
      create_webhook_on_space(payload, headers)
    end

    # Create submission webhook
    #
    # @param kapp_slug [String] slug of the Kapp the submission webhook belongs to
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - Closed | Created | Deleted | Saved | Submitted | Updated
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_submission_webhook(kapp_slug, webhook_properties, headers=default_headers)
      raise StandardError.new "Webhook properties is not valid, must be a Hash." unless webhook_properties.is_a? Hash
      payload = { "type" => "Submission" }.merge(webhook_properties)
      create_webhook_on_kapp(kapp_slug, payload, headers)
    end

    # Create user webhook
    #
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - Login | Logout
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_user_webhook(webhook_properties, headers=default_headers)
      raise StandardError.new "Webhook properties is not valid, must be a Hash." unless webhook_properties.is_a? Hash
      payload = { "type" => "User" }.merge(webhook_properties)
      create_webhook_on_space(payload, headers)
    end

    # Create a webhook on a Kapp (either a Form or Submission webhook)
    #
    # Ideally the shortcut methods (create_form_webhook,
    # create_submission_webhook) would be used instead of this one.
    #
    # @param kapp_slug [String] slug of the Kapp the webhook belongs to
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - depends on +type+
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    #   - +type+ - The type of model the webhook is bound to: Form | Submission
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_webhook_on_kapp(kapp_slug, webhook_properties, headers=default_headers)
      raise StandardError.new "Webhook properties is not valid, must be a Hash." unless webhook_properties.is_a? Hash
      puts "Creating a \"#{webhook_properties['event']}\" \"#{webhook_properties['type']}\" webhook for #{kapp_slug}"
      post("#{@api_url}/kapps/#{kapp_slug}/webhooks", webhook_properties, headers)
    end

    # Create a webhook on a Space (either a Space or User webhook)
    #
    # Ideally the shortcut methods (create_space_webhook, create_user_webhook)
    # would be used instead of this one.
    #
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - depends on +type+
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    #   - +type+ - The type of model the webhook is bound to: Space | User
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def create_webhook_on_space(webhook_properties, headers=default_headers)
      raise StandardError.new "Webhook properties is not valid, must be a Hash." unless webhook_properties.is_a? Hash
      puts "Creating a \"#{webhook_properties['event']}\" \"#{webhook_properties['type']}\" webhook"
      post("#{@api_url}/webhooks", webhook_properties, headers)
    end

    # List all webhooks for a Kapp
    #
    # @param kapp_slug [String] the Kapp slug
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def list_webhooks_on_kapp(kapp_slug, params={}, headers=default_headers)
      puts "Retrieving all webhooks on the \"#{kapp_slug}\" Kapp"
      get("#{@api_url}/kapps/#{kapp_slug}/webhooks", params, headers)
    end

    # List all webhooks for a Space
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def list_webhooks_on_space(params={}, headers=default_headers)
      puts "Retrieving all webhooks on the Space"
      get("#{@api_url}/webhooks", params, headers)
    end

    # Retrieve a webhook defined in a Kapp
    #
    # @param kapp_slug [String] the Kapp slug
    # @param name [String] the webhook name
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_webhook_on_kapp(kapp_slug, name, params={}, headers=default_headers)
      puts "Retrieving the \"#{name}\" webhook on the \"#{kapp_slug}\" Kapp"
      get("#{@api_url}/kapps/#{kapp_slug}/webhooks/#{url_encode(name)}", params, headers)
    end

    # Retrieve a webhook defined in a Space
    #
    # @param name [String] the webhook name
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def retrieve_webhook_on_space(name, params={}, headers=default_headers)
      puts "Retrieving the \"#{name}\" webhook on the Space"
      get("#{@api_url}/webhooks/#{url_encode(name)}", params, headers)
    end

    # Update a webhook on a Kapp (either a Form or Submission webhook)
    #
    # All of the webhook properties are optional.  Only the properties provided
    # in the Hash will be updated, the other properties will retain their
    # current values.
    #
    # @param kapp_slug [String] the Kapp slug
    # @param name [String] the webhook name
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - depends on +type+
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    #   - +type+ - The type of model the webhook is bound to: Form | Submission
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_webhook_on_kapp(kapp_slug, name, webhook_properties, headers=default_headers)
      puts "Updating the \"#{name}\" webhook on the \"#{kapp_slug}\" Kapp"
      put("#{@api_url}/kapps/#{kapp_slug}/webhooks/#{url_encode(name)}", webhook_properties, headers)
    end


    # Update a webhook on a Space (either a Space or User webhook)
    #
    # All of the webhook properties are optional.  Only the properties provided
    # in the Hash will be updated, the other properties will retain their
    # current values.
    #
    # @param name [String] the webhook name
    # @param webhook_properties [Hash] hash of webhook properties
    #   - +event+ - depends on +type+
    #   - +name+ - A descriptive name for the webhook
    #   - +filter+ - A javascript expression to determine when the webhook should fire
    #   - +url+ - URL to post the bindings when the event is triggered
    #   - +type+ - The type of model the webhook is bound to: Space | User
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def update_webhook_on_space(name, webhook_properties, headers=default_headers)
      puts "Updating the \"#{name}\" webhook on the Space"
      put("#{@api_url}/webhooks/#{url_encode(name)}", webhook_properties, headers)
    end

  end
end
