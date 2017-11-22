module KineticSdk
  class Task

    # Complete a Deferred Task
    #
    # @param source_name [String] - name of the source
    # @param body [Hash] properties that are sent to update the task
    #   - +token+ - the token linked to the deferred task
    # @param headers [Hash] hash of headers to send, default is basic authentication and JSON content type
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def complete_deferred_task(source_name, body, headers=default_headers)
      puts "Completing deferred task for the \"#{source_name}\" Source."
      post("#{@api_v1_url}/complete-deferred-task/#{url_encode(source_name)}", body, headers)
    end

  end
end
