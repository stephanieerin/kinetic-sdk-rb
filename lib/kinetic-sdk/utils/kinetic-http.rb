require 'base64'
require 'erb'
require 'mime/types'
require 'net/http'
require 'net/http/post/multipart'

# The KineticSdk module contains functionality to interact with Kinetic Data applications
# using their built-in REST APIs.
module KineticSdk

  # A utilities module that can be used by multiple libraries.
  module Utils

    # The KineticHttpUtils module provides common HTTP methods, and returns a 
    # KineticSdk::Utils::KineticHttpResponse object with all methods. The
    # raw Net::HTTPResponse is available by calling the 
    # KineticHttpRespone#response method.
    module KineticHttpUtils

      # Include the Logger module
      include KineticSdk::Utils::Logger

      # Send an HTTP DELETE request
      # 
      # @param url [String] url to send the request to
      # @param headers [Hash] hash of headers to send
      # @param redirect_limit [Fixnum] max number of times to redirect
      # @return [KineticSdk::Utils::KineticHttpResponse] response
      def delete(url, headers={}, redirect_limit=max_redirects)
        # parse the URL
        uri = URI.parse(url)

        debug("DELETE #{uri}  #{headers.inspect}")

        # build the http object
        http = Net::HTTP.new(uri.host, uri.port)
        http.set_debug_output($stdout) if trace?
        http.use_ssl = (uri.scheme == 'https')
        # build the request
        request = Net::HTTP::Delete.new(uri.request_uri, headers)

        # send the request
        begin
          response = http.request(request)
          # handle the response
          case response
          when Net::HTTPRedirection then
            raise Net::HTTPFatalError.new("Too many redirects", response) if redirect_limit == 0
            delete_raw(response['location'], headers, redirect_limit - 1)
          else
            KineticHttpResponse.new(response)
          end
        rescue StandardError => e
          KineticHttpResponse.new(e)
        end
      end

      # Send an HTTP GET request
      # 
      # @param url [String] url to send the request to
      # @param params [Hash] Query parameters that are added to the URL, such as +include+
      # @param headers [Hash] hash of headers to send
      # @param redirect_limit [Fixnum] max number of times to redirect
      # @return [KineticSdk::Utils::KineticHttpResponse] response
      def get(url, params={}, headers={}, redirect_limit=max_redirects)
        # parse the URL
        uri = URI.parse(url)
        # add URL parameters
        uri.query = URI.encode_www_form(params)

        debug("GET #{uri}  #{headers.inspect}")

        # build the http object
        http = Net::HTTP.new(uri.host, uri.port)
        http.set_debug_output($stdout) if trace?
        http.use_ssl = (uri.scheme == 'https')
        # build the request
        request = Net::HTTP::Get.new(uri.request_uri, headers)

        # send the request
        begin
          response = http.request(request)
          # handle the response
          case response
          when Net::HTTPRedirection then
            raise Net::HTTPFatalError.new("Too many redirects", response) if redirect_limit == 0
            get_raw(response['location'], params, headers, redirect_limit - 1)
          else
            KineticHttpResponse.new(response)
          end
        rescue StandardError => e
          KineticHttpResponse.new(e)
        end
      end

      # Send an HTTP PATCH request
      # 
      # @param url [String] url to send the request to
      # @param data [Hash] the payload to send with the request
      # @param headers [Hash] hash of headers to send
      # @param redirect_limit [Fixnum] max number of times to redirect
      # @return [KineticSdk::Utils::KineticHttpResponse] response
      def patch(url, data={}, headers={}, redirect_limit=max_redirects)
        # parse the URL
        uri = URI.parse(url)

        debug("PATCH #{uri}  #{headers.inspect}")

        # unless the data is already a string, assume JSON and convert to string
        data = data.to_json unless data.is_a? String
        # build the http object
        http = Net::HTTP.new(uri.host, uri.port)
        http.set_debug_output($stdout) if trace?
        http.use_ssl = (uri.scheme == 'https')
        # build the request
        request = Net::HTTP::Patch.new(uri.request_uri, headers)
        request.body = data

        # send the request
        begin
          response = http.request(request)
          # handle the response
          case response
          when Net::HTTPRedirection then
            raise Net::HTTPFatalError.new("Too many redirects", response) if redirect_limit == 0
            patch_raw(response['location'], data, headers, redirect_limit - 1)
          else
            KineticHttpResponse.new(response)
          end
        rescue StandardError => e
          KineticHttpResponse.new(e)
        end
      end

      # Send an HTTP POST request
      # 
      # @param url [String] url to send the request to
      # @param data [Hash] the payload to send with the request
      # @param headers [Hash] hash of headers to send
      # @param redirect_limit [Fixnum] max number of times to redirect
      # @return [KineticSdk::Utils::KineticHttpResponse] response
      def post(url, data={}, headers={}, redirect_limit=max_redirects)
        # parse the URL
        uri = URI.parse(url)

        debug("POST #{uri}  #{headers.inspect}")

        # unless the data is already a string, assume JSON and convert to string
        data = data.to_json unless data.is_a? String
        # build the http object
        http = Net::HTTP.new(uri.host, uri.port)
        http.set_debug_output($stdout) if trace?
        http.use_ssl = (uri.scheme == 'https')
        # build the request
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = data

        # send the request
        begin
          response = http.request(request)
          # handle the response
          case response
          when Net::HTTPRedirection then
            raise Net::HTTPFatalError.new("Too many redirects", response) if redirect_limit == 0
            post_raw(response['location'], data, headers, redirect_limit - 1)
          else
            KineticHttpResponse.new(response)
          end
        rescue StandardError => e
          KineticHttpResponse.new(e)
        end
      end

      # Send a Multipart HTTP POST request
      # 
      # @param url [String] url to send the request to
      # @param data [Hash] payload to send with the request
      # @param headers [Hash] hash of headers to send
      # @param redirect_limit [Fixnum] max number of times to redirect
      # @return [KineticSdk::Utils::KineticHttpResponse] response
      def post_multipart(url, data={}, headers={}, redirect_limit=max_redirects)
        # the Content-Type header is handled automoatically by Net::HTTP::Post::Multipart
        headers.delete_if { |k,v| k.to_s.downcase == "content-type" }

        debug("POST #{url}  #{headers.inspect}  multi-part form content")

        # parse the URL
        uri = URI.parse(url)

        # prepare the payload
        payload = data.inject({}) do |h,(k,v)| 
          h[k] = (v.class == File) ? UploadIO.new(v, mimetype(v), File.basename(v)) : v; h
        end

        # build the http object
        http = Net::HTTP.new(uri.host, uri.port)
        http.set_debug_output($stdout) if trace?
        http.use_ssl = (uri.scheme == 'https')
        # build the request
        request = Net::HTTP::Post::Multipart.new(uri.request_uri, payload)
        headers.each { |k,v| request.add_field(k, v) }
        # send the request
        begin
          response = http.request(request)
          # handle the response
          case response
          when Net::HTTPRedirection then
            raise Net::HTTPFatalError.new("Too many redirects", response) if redirect_limit == 0
            post_multipart_raw(response['location'], data, headers, redirect_limit - 1)
          else
            KineticHttpResponse.new(response)
          end
        rescue StandardError => e
          KineticHttpResponse.new(e)
        end
      end

      # Send an HTTP PUT request
      # 
      # @param url [String] url to send the request to
      # @param data [Hash] payload to send with the request
      # @param headers [Hash] hash of headers to send
      # @param redirect_limit [Fixnum] max number of times to redirect
      # @return [KineticSdk::Utils::KineticHttpResponse] response
      def put(url, data={}, headers={}, redirect_limit=max_redirects)
        # parse the URL
        uri = URI.parse(url)

        debug("PUT #{uri}  #{headers.inspect}")

        # unless the data is already a string, assume JSON and convert to string
        data = data.to_json unless data.is_a? String
        # build the http object
        http = Net::HTTP.new(uri.host, uri.port)
        http.set_debug_output($stdout) if trace?
        http.use_ssl = (uri.scheme == 'https')
        # build the request
        request = Net::HTTP::Put.new(uri.request_uri, headers)
        request.body = data

        # send the request
        begin
          response = http.request(request)
          # handle the response
          case response
          when Net::HTTPRedirection then
            raise Net::HTTPFatalError.new("Too many redirects", response) if redirect_limit == 0
            put_raw(response['location'], data, headers, redirect_limit - 1)
          else
            KineticHttpResponse.new(response)
          end
        rescue StandardError => e
          KineticHttpResponse.new(e)
        end
      end

      # alias methods to allow wrapper modules to handle the
      # response object.
      alias_method :delete_raw, :delete
      alias_method :get_raw, :get
      alias_method :patch_raw, :patch
      alias_method :post_raw, :post
      alias_method :post_multipart_raw, :post_multipart
      alias_method :put_raw, :put


      # Provides a accepts header set to application/json
      #
      # @return [Hash] Accepts header set to application/json
      def header_accepts_json
        { "Accepts" => "application/json" }
      end

      # Provides a basic authentication header
      # 
      # @param username [String] username to authenticate
      # @param password [String] password associated to the username
      # @return [Hash] Authorization: Basic base64 hash of username and password
      def header_basic_auth(username=@username, password=@password)
        { "Authorization" => "Basic #{Base64.encode64(username.to_s + ":" + password.to_s).gsub("\n", "")}" }
      end

      # Provides a content-type header set to application/json
      #
      # @return [Hash] Content-Type header set to application/json
      def header_content_json
        { "Content-Type" => "application/json" }
      end

      # Provides a user-agent header set to Kinetic Ruby SDK
      #
      # @return [Hash] User-Agent header set to Kinetic Reuby SDK
      def header_user_agent
        { "User-Agent" => "Kinetic Ruby SDK #{KineticSdk.version}" }
      end

      # Provides a hash of default headers
      #
      # @param username [String] username to authenticate
      # @param password [String] password associated to the username
      # @return [Hash] Hash of headers
      #   - Accepts: application/json
      #   - Authorization: Basic base64 hash of username and password if username is provided
      #   - Content-Type: application/json
      #   - User-Agent: Kinetic Ruby SDK {KineticSdk.version}
      def default_headers(username=@username, password=@password)
        headers = header_accepts_json.merge(header_content_json).merge(header_user_agent)
        headers.merge!(header_basic_auth(username, password)) unless username.nil?
        headers
      end

      # Encode URI components
      #
      # @param parameter [String] parameter value to encode
      # @return [String] URL encoded parameter value
      def encode(parameter)
        ERB::Util.url_encode parameter
      end

      # Determines the mime-type of a file
      # 
      # @param file [File | String] file or filename to detect
      # @return [Array] MIME::Type of the file
      def mimetype(file)
        mime_type = MIME::Types.type_for(file.class == File ? File.basename(file) : file)
        if mime_type.size == 0
          mime_type = MIME::Types['text/plain'] 
        end
        mime_type
      end

      # The maximum number of times to follow redirects.
      #
      # Can be passed in as an option when initializing the SDK
      # with either the @options[:max_redirects] or @options['max_redirects']
      # key.
      #
      # Expects an integer [Fixnum] value. Setting to 0 will disable redirects.
      #
      # @return [Fixnum] default 5
      def max_redirects
        limit = @options &&
        (
          @options[:max_redirects] ||
          @options['max_redirects']
        )
        limit.nil? ? 5 : limit.to_i
      end

    end


    # The KineticHttp class provides functionality to make generic HTTP requests.
    class KineticHttp

      include KineticSdk::Utils::KineticHttpUtils

      # The username used in the Basic Authentication header
      attr_reader :username
      # The password used in the Basic Authentication header
      attr_reader :password

      # Constructor
      #
      # @param username [String] username for Basic Authentication
      # @param password [String] password for Basic Authentication
      def initialize(username=nil, password=nil)
        @username = username
        @password = password
      end

    end
    

    # The KineticHttpResponse object normalizes the HTTP response object
    # properties so they are consistent regardless of what HTTP library is used.
    #
    # If the object passed in the constructor is a StandardError, the status code is
    # set to 0, and the #exception and #backtrace methods can be used to get the 
    # details.
    #
    # Regardless of whether an HTTP Response object or a StandardError object was 
    # passed in the constructor, the #code and #message methods will give information
    # about the response.
    class KineticHttpResponse
      # response code [String] - always '0' if constructor object is a StandardError
      attr_reader :code
      # the parsed JSON response body if content-type is application/json
      attr_accessor :content
      # the raw response body string
      attr_accessor :content_string
      # the response content-type
      attr_reader :content_type
      # the resonse headers
      attr_reader :headers
      # response status message
      attr_reader :message
      # the raw response object
      attr_reader :response
      # response code [Fixnum] - always 0 if constructor object is a StandardError
      attr_reader :status
      
      # the StandardError backtrace if constructor object is a StandardError
      attr_reader :backtrace
      # the raw StandardError if constructor object is a StandardError
      attr_reader :exception

      # Constructor
      #
      # @param object [Net::HTTPResponse | StandardError] either an HTTP Response or a StandardError
      def initialize(object)
        case object
        when Net::HTTPResponse then
          @code = object.code
          @content_string = object.body
          @content_type = object.content_type
          @headers = object.each_header.inject({}) { |h,(k,v)| h[k] = v; h }
          @message = object.message
          @response = object
          @status = @code.to_i

          # if content type is json, try to parse the content string
          @content = case @content_type
            when "application/json" then
              # will raise an exception if content_string is not valid json
              JSON.parse(@content_string)
            else
              nil
            end
        when StandardError then
          @code = "0"
          @backtrace = object.backtrace
          @exception = object.exception
          @message = object.message
          @status = @code.to_i
        else
          raise StandardError.new("Invalid response object: #{object.class}")
        end
      end
    end

  end
end
