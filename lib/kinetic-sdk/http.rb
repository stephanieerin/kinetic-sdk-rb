require 'erb'

# The KineticSdk module contains functionality to interact with Kinetic Data applications
# using their built-in REST APIs.
module KineticSdk

  # The Http class provides common HTTP methods used by all Kinetic Data application SDKs.
  #
  # All HTTP requests are handled using the {Rest Client}[https://github.com/rest-client/rest-client] gem.
  module Http

    # Indicates if the log level is set to debug
    #
    # @return [Boolean] true if debug, else false
    def debug?
      !@options.nil? && 
      (
        @options[:log_level].to_s.downcase == "debug" || 
        @options['log_level'].to_s.downcase == "debug"
      )
    end

    # Encode URI components
    #
    # @param parameter [String] parameter value to URL encode
    # @return [String] URL encoded parameter value
    def encode(parameter)
      ERB::Util.url_encode parameter
    end

  end
end
