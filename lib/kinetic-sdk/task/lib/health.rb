module KineticSdk
  class Task

    # Checks if the web application is alive
    #
    # @param url [String] the url to query for a 200 response code
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def is_alive?(url, headers=header_basic_auth)
      response = get(url, {}, headers)
      response.status == 200
    end

    # Waits until the web server is alive
    #
    # @param url [String] the url to query for a 200 response code
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [KineticSdk::Utils::KineticHttpResponse] object, with +code+, +message+, +content_string+, and +content+ properties
    def wait_until_alive(url, headers=header_basic_auth)
      url = url[1..-1] if url.start_with?("/")
      while !is_alive?("#{@api_url}/#{url}", headers) do
        info("Web server is not ready, waiting...")
        sleep 3
      end
    end

  end
end
