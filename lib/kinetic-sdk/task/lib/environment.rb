module KineticSdk
  class Task

    # Get the web server environment
    #
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def environment(params={}, headers=header_basic_auth)
      get("#{@api_url}/environment", params, headers)
    end

  end
end
