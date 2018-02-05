module KineticSdk
  module Utils

    # The Random module provides methods to generate random secrets of varying
    # complexity.
    module Random

      # Generates a simple secret based on ASCII alpha-numeric characters,
      # and a few standard symbol characters.
      #
      # @param size [Fixnum] The length of the generated secret
      # @param allowed_symbols [Array] symbols to allow
      def self.simple(size = 20, allowed_symbols = [ '!', '@', '%', '*', '(', ')', '{', '}', '[', ']' ])
        chars = (allowed_symbols || Array.new).concat(
          ('A'..'Z').to_a).concat(
            ('a'..'z').to_a).concat(
              ('0'..'9').to_a)
        (0...size).map { chars[rand(chars.size)] }.join
      end

    end
  end
end