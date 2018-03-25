module DegUsaTax
  module Bitcoin
    class Wallet
      attr_reader :name
      attr_reader :addresses

      def initialize(name, opts = {})
        @name = name.to_sym
        @addresses = []
        @balance_map = {}

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

      def balance(symbol)
        @balance_map.fetch(symbol, 0)
      end

      def add_balance(symbol, amount)
        @balance_map[symbol] ||= 0
        @balance_map[symbol] += amount
      end

      def symbols
        @balance_map.keys
      end
    end
  end
end
