require 'rest-client'

# The KineticSdk module contains functionality to interact with Kinetic Data applications
# using their built-in REST APIs.
module KineticSdk

  # The Http class provides common HTTP methods used by all Kinetic Data application SDKs.
  #
  # All HTTP requests are handled using the {Rest Client}[https://github.com/rest-client/rest-client] gem.
  #
  module Http

    # Make a HTTP DELETE request
    # 
    # @param url [String] url to send the request to
    # @param headers [Hash] hash of headers to send
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def delete(url, headers={})
      response = nil

      begin
        puts "DELETE #{url}  #{headers.inspect}" if debug?
        # send the request
        response = RestClient::Request.execute(
            method: :delete,
            url: url,
            timeout: 60,
            headers: headers)
      rescue RestClient::ExceptionWithResponse => e
        if e.response.nil?
          puts "  ** #{e.inspect}"
        else
          puts "  ** #{e.response.code} #{e.response.body}"
        end
      rescue StandardError => e
        puts "  ** #{e.inspect}"
      end
      # return the response
      response
    end


    # Make a HTTP GET request
    # 
    # @param url [String] url to send the request to
    # @param params [Hash] Query parameters that are added to the URL, such as +include+
    # @param headers [Hash] hash of headers to send
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def get(url, params={}, headers={})
      response = nil

      # merge the pameters hash into the headers
      headers = headers.merge({ :params => params })

      begin
        response = nil
        puts "GET #{url}  #{headers.inspect}" if debug?
        # send the request
        response = RestClient::Request.execute(
            method: :get,
            url: url,
            timeout: 60,
            headers: headers)
      rescue RestClient::ExceptionWithResponse => e
        if e.response.nil?
          puts "  ** #{e.inspect}"
        else
          puts "  ** #{e.response.code} #{e.response.body}"
        end
      rescue StandardError => e
        puts "  ** #{e.inspect}"
      end
      # return the response
      response
    end

    # Make a HTTP PATCH request
    # 
    # @param url [String] url to send the request to
    # @param data [Hash] the payload to send with the request
    # @param headers [Hash] hash of headers to send
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def patch(url, data={}, headers={})
      response = nil
      # unless the data is already a string, assume JSON and convert to string
      data = data.to_json unless data.is_a? String

      begin
        puts "PATCH #{url}  #{headers.inspect}  #{data.inspect}" if debug?
        # send the request
        response = RestClient::Request.execute(
            method: :patch,
            url: url,
            payload: data,
            timeout: 60,
            headers: headers)
      rescue RestClient::ExceptionWithResponse => e
        if e.response.nil?
          puts "  ** #{e.inspect}"
        else
          puts "  ** #{e.response.code} #{e.response.body}"
        end
      rescue StandardError => e
        puts "  ** #{e.inspect}"
      end
      # return the response
      response
    end

    # Make a HTTP POST request
    # 
    # @param url [String] url to send the request to
    # @param data [Hash] the payload to send with the request
    # @param headers [Hash] hash of headers to send
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def post(url, data={}, headers={})
      response = nil
      # unless the data is already a string, assume JSON and convert to string
      data = data.to_json unless data.is_a? String

      begin
        puts "POST #{url}  #{headers.inspect}  #{data.inspect}" if debug?
        # send the request
        response = RestClient::Request.execute(
            method: :post,
            url: url,
            payload: data,
            timeout: 60,
            headers: headers)
      rescue RestClient::ExceptionWithResponse => e
        if e.response.nil?
          puts "  ** #{e.inspect}"
        else
          puts "  ** #{e.response.code} #{e.response.body}"
        end
      rescue StandardError => e
        puts "  ** #{e.inspect}"
      end
      # return the response
      response
    end

    # Make a Multipart HTTP POST request
    # 
    # @param url [String] url to send the request to
    # @param data [Hash] payload to send with the request
    # @param headers [Hash] hash of headers to send
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def post_multipart(url, data={}, headers={})
      response = nil

      begin
        puts "POST #{url}  #{headers.inspect}  multi-part form content" if debug?
        # send the request
        response = RestClient::Request.execute(
            method: :post,
            url: url,
            payload: data,
            timeout: 60,
            headers: headers)
      rescue RestClient::ExceptionWithResponse => e
        if e.response.nil?
          puts "  ** #{e.inspect}"
        else
          puts "  ** #{e.response.code} #{e.response.body}"
        end
      rescue StandardError => e
        puts "  ** #{e.inspect}"
      end
      # return the response
      response
    end

    # Make a HTTP PUT request
    # 
    # @param url [String] url to send the request to
    # @param data [Hash] payload to send with the request
    # @param headers [Hash] hash of headers to send
    # @return [RestClient::Response] Response object, with +code+ and +body+ properties
    def put(url, data={}, headers={})
      response = nil
      # unless the data is already a string, assume JSON and convert to string
      data = data.to_json unless data.is_a? String

      begin
        puts "PUT #{url}  #{headers.inspect}  #{data.inspect}" if debug?
        # send the request
        response = RestClient::Request.execute(
            method: :put,
            url: url,
            payload: data,
            timeout: 60,
            headers: headers)
      rescue RestClient::ExceptionWithResponse => e
        if e.response.nil?
          puts "  ** #{e.inspect}"
        else
          puts "  ** #{e.response.code} #{e.response.body}"
        end
      rescue StandardError => e
        puts "  ** #{e.inspect}"
      end
      # return the response
      response
    end

  end
end
