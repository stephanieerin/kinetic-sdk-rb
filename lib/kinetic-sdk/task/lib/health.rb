module KineticSdk
  class Task

    # Checks if the web application is alive
    #
    # @param url [String] the url to query for a 200 response code
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def is_alive?(url, headers=header_basic_auth)
      alive = false
      begin
        response = get(url, {}, headers)
        alive = !response.nil? && response.code == 200
      rescue Errno::ECONNREFUSED
        puts "#{$!.inspect}"
      end
      alive
    end

    # Waits until the web server is alive
    #
    # @param url [String] the url to query for a 200 response code
    # @param headers [Hash] hash of headers to send, default is basic authentication
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def wait_until_alive(url, headers=header_basic_auth)
      while !is_alive?(url, headers) do
        puts "Web server is not ready, waiting..."
        sleep 3
      end
    end

  end
end
