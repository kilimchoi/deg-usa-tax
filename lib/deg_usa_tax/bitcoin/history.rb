module DegUsaTax
  module Bitcoin
    # This class keeps track of your entire history with Bitcoin.
    # It helps prepare taxes and also just check where your Bitcoins are.
    class History
      include OptionChecker

      attr_reader :wallets

      def initialize(opts = {})
        @lot_tracker = opts.fetch(:lot_tracker) { FifoLotFinder.new }
        @wallets = {}
      end

      def create_wallet(name, opts = {})
        raise ArgumentError, "Wallet name should be a symbol." if !name.is_a?(Symbol)
        @wallets[name] = Wallet.new(name, opts)
      end

      def wallet(name)
        @wallets.fetch(name)
      end

      def buy_btc_with_usd(date, amount_btc, amount_usd, wallet, opts = {})
        amount_btc = Bitcoin.normalize_positive_bitcoin(amount_btc)
        amount_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(amount_usd)
        wallet = normalize_wallet(wallet)

        check_opts opts, [:txid]

        unless wallet.off_chain?
          # TODO: do something with the txid provided by the user
        end

        transaction = Transaction.new(date, :purchase, amount_btc, amount_usd)
        @lot_tracker.add_transaction(transaction)

        wallet.balance += amount_btc
      end

      def donate_btc(date, amount_btc, wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount_btc = Bitcoin.normalize_positive_bitcoin(amount_btc)
        wallet = normalize_wallet(wallet)

        check_opts opts, [:for, :txid, :fee]

        # TODO: do something with the txid

        fee = Bitcoin.normalize_nonnegative_bitcoin(opts.fetch(:fee, 0))

        if wallet.balance < amount_btc + fee
          raise "Wallet only has #{wallet.balance}, cannot donate #{amount_btc} + #{fee}."
        end

        wallet.balance -= amount_btc + fee

        transaction = Transaction.new(date, :donation, amount_btc + fee, 0)
        @lot_tracker.add_transaction(transaction)
      end

      def move_btc(date, amount_btc, source_wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount_btc = Bitcoin.normalize_positive_bitcoin(amount_btc)
        source_wallet = normalize_wallet(source_wallet)

        check_opts opts, [:fee, :txid, :to]

        fee = Bitcoin.normalize_nonnegative_bitcoin(opts.fetch(:fee, 0))
        dest_wallet = normalize_wallet(opts.fetch(:to))

        # TODO: do something with the txid

        if source_wallet.balance < amount_btc + fee
          raise "Wallet only has #{source_wallet.balance.to_s('F')}, " \
                "cannot move #{amount_btc.to_s('F')} + #{fee.to_s('F')}."
        end

        source_wallet.balance -= (amount_btc + fee)
        dest_wallet.balance += amount_btc

        add_fee_if_needed(date, fee)
      end

      def purchase_with_btc(date, amount_btc, market_value_usd, wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount_btc = Bitcoin.normalize_positive_bitcoin(amount_btc)
        market_value_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(market_value_usd)
        wallet = normalize_wallet(wallet)

        check_opts opts, [:for, :fee, :txid]

        fee = Bitcoin.normalize_nonnegative_bitcoin(opts.fetch(:fee, 0))

        if wallet.balance < amount_btc + fee
          raise "Wallet only has #{wallet.balance}, cannot spend #{amount_btc} + #{fee}."
        end

        wallet.balance -= (amount_btc + fee)

        add_fee_if_needed(date, fee)

        transaction = Transaction.new(date, :sale, amount_btc, market_value_usd)
        @lot_tracker.add_transaction(transaction)
      end

      def income_btc(date, amount_btc, market_value_usd, wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount_btc = Bitcoin.normalize_positive_bitcoin(amount_btc)
        market_value_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(market_value_usd)
        wallet = normalize_wallet(wallet)

        wallet.balance += amount_btc

        check_opts opts, [:for, :txid]

        transaction = Transaction.new(date, :purchase, amount_btc, market_value_usd)
        @lot_tracker.add_transaction transaction
      end

      def assert_equal(expected, actual)
        if expected != actual
          raise "Expected #{expected}, got #{actual}."
        end
      end

      def assert_balance(wallet, expected_balance)
        wallet = normalize_wallet(wallet)
        expected_balance = Bitcoin.normalize_nonnegative_bitcoin(expected_balance)
        actual_balance = wallet.balance
        if expected_balance != actual_balance
          diff = actual_balance - expected_balance
          raise 'Expected %s balance of %s, got %s.  Difference: %s' %
                [wallet.name, expected_balance.to_s('F'),
                 actual_balance.to_s('F'), diff.to_s('F')]
        end
      end

      private

      def normalize_wallet(wallet)
        case wallet
        when Symbol then @wallets.fetch(wallet)
        when Wallet then wallet
        else raise ArgumentError, "Not a wallet: #{wallet.inspect}"
        end
      end

      def add_fee_if_needed(date, fee)
        if !fee.zero?
          transaction = Transaction.new(date, :donation, fee, 0)
          @lot_tracker.add_transaction(transaction)
        end
      end
    end
  end
end
