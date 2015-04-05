module DegUsaTax
  module Bitcoin
    class Wallet
      attr_reader :name
      attr_reader :addresses

      # I am skeptical of whether the 'balance' feature should be here.
      attr_accessor :balance

      def initialize(name, opts = {})
        @name = name.to_sym
        @addresses = []
        @balance = 0

        valid_keys = [:off_chain]
        invalid_keys = opts.keys - valid_keys
        if !invalid_keys.empty?
          raise ArgumentError, "Invalid keys: #{invalid_keys.join(', ')}"
        end

        @off_chain = opts.fetch(:off_chain, false) ? true : false
      end

      def off_chain?
        @off_chain
      end
    end
  end
end
