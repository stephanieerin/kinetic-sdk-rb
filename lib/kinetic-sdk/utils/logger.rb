module KineticSdk
  module Utils

    # The Logger module provides methods to output at different levels based on 
    # a configuration property.  The default log level is 'off', but can be 
    # turned on by passing in the 'log_level' option.
    module Logger

      # Logs the message if the log level is set to debug or lower.
      #
      # @param message [String] The message to log at debug level
      def debug(message)
        puts message if debug?
      end

      # Indicates if the log level is set to debug or lower.
      #
      # @return [Boolean] true if debug or trace, else false
      def debug?
        @options && 
        (
          @options[:log_level].to_s.downcase == "debug" || 
          @options['log_level'].to_s.downcase == "debug" ||
          trace?
        )
      end

      # Logs the message if the log level is set to info or lower.
      #
      # @param message [String] The message to log at info level
      def info(message)
        puts message if info?
      end

      # Indicates if the log level is set to info or lower.
      #
      # @return [Boolean] true if info, debug or trace, else false
      def info?
        @options && 
        (
          @options[:log_level].to_s.downcase == "info" || 
          @options['log_level'].to_s.downcase == "info" ||
          debug?
        )
      end

      # Logs the message if the log level is set to trace.
      #
      # @param message [String] The message to log at trace level
      def trace(message)
        puts message if trace?
      end

      # Indicates if the log level is set to trace.
      #
      # @return [Boolean] true if trace, else false
      def trace?
        @options && 
        (
          @options[:log_level].to_s.downcase == "trace" || 
          @options['log_level'].to_s.downcase == "trace"
        )
      end

    end
  end
end
