require 'base64'

module KineticSdk
  module Http

    # Provides a basic authentication header
    # 
    # @param username [String] username to authenticate
    # @param password [String] password associated to the username
    # @return [Hash] Authorization: Basic base64 hash of username and password
    def header_basic_auth(username=@login, password=@password)
      { :Authorization => Base64.encode64(username + ":" + password).gsub("\n", "") }
    end

    # Provides a content-type header set to application/json
    #
    # @return [Hash] Content-Type header set to application/json
    def header_content_json
      { :content_type => :json }
    end

    # Provides a accepts header set to application/json
    #
    # @return [Hash] Accepts header set to application/json
    def header_accepts_json
      { :Accepts => :json }
    end

    # Provides a hash of default headers
    #
    # @param username [String] username to authenticate
    # @param password [String] password associated to the username
    # @return [Hash] Hash of headers
    #   - Authorization: Basic base64 hash of username and password
    #   - Content-Type: application/json
    #   - Accepts: application/json
    def default_headers(username=@login, password=@password)
      header_basic_auth(username, password).merge(header_content_json).merge(header_accepts_json)
    end

  end
end
