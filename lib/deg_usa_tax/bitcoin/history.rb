# TODO: ethereum is divisible to 18 decimal places so we need to call
# normalization functions that are specific to each crypto

module DegUsaTax
  module Bitcoin
    module CommandsBtc
      def buy_btc_with_usd(date, amount_btc, amount_usd, wallet, opts = {})
        buy_crypto_with_usd(date, :btc, amount_btc, amount_usd, wallet, opts)
      end

      def donate_btc(date, amount, wallet, opts = {})
        donate_crypto(date, :btc, amount, wallet, opts)
      end

      def move_btc(date, amount, source_wallet, opts = {})
        move_crypto(date, :btc, amount, source_wallet, opts)
      end

      def purchase_with_btc(date, amount_btc, market_value_usd, wallet, opts = {})
        purchase_with_crypto(date, :btc, amount_btc, market_value_usd, wallet, opts)
      end

      def income_btc(date, amount_btc, market_value_usd, wallet, opts = {})
        income_crypto(date, :btc, amount_btc, market_value_usd, wallet, opts = {})
      end
    end

    # This class keeps track of your entire history with Bitcoin.
    # It helps prepare taxes and also just check where your Bitcoins are.
    class History
      include OptionChecker
      include CommandsBtc

      attr_reader :wallets, :incomes

      def initialize(opts = {})
        @lot_tracker_map = {}
        @incomes = []
        @wallets = {}
      end

      # For dependency injection in unit tests.
      def set_lot_tracker(symbol, tracker)
        @lot_tracker_map[symbol] = tracker
      end

      def lot_tracker(symbol)
        @lot_tracker_map[symbol] ||= FifoLotFinder.new
      end

      def record_income(date, amount_usd, desc)
        @incomes << Income.new(date, amount_usd, desc)
      end

      def create_wallet(name, opts = {})
        raise ArgumentError, "Wallet name should be a symbol." if !name.is_a?(Symbol)
        @wallets[name] = Wallet.new(name, opts)
      end

      def wallet(name)
        @wallets.fetch(name)
      end

      def buy_crypto_with_usd(date, symbol, amount_crypto, amount_usd, wallet, opts = {})
        amount_crypto = Bitcoin.normalize_positive_bitcoin(amount_crypto)
        amount_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(amount_usd)
        wallet = normalize_wallet(wallet)
        check_opts opts, [:txid]

        transaction = Transaction.new(date, :purchase, amount_crypto, amount_usd)
        lot_tracker(symbol).add_transaction(transaction)
        wallet.add_balance(symbol, amount_crypto)
      end

      def donate_crypto(date, symbol, amount, wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount = Bitcoin.normalize_positive_bitcoin(amount)
        wallet = normalize_wallet(wallet)

        check_opts opts, [:for, :txid, :fee]

        fee = Bitcoin.normalize_nonnegative_bitcoin(opts.fetch(:fee, 0))

        if wallet.balance(symbol) < amount + fee
          raise "Wallet only has #{wallet.balance}, cannot donate #{amount} + #{fee}."
        end

        wallet.add_balance symbol, -(amount + fee)

        transaction = Transaction.new(date, :donation, amount + fee, 0)
        lot_tracker(:btc).add_transaction(transaction)
      end

      def move_crypto(date, symbol, amount, source_wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount_btc = Bitcoin.normalize_positive_bitcoin(amount)
        source_wallet = normalize_wallet(source_wallet)

        check_opts opts, [:fee, :txid, :to]

        fee = Bitcoin.normalize_nonnegative_bitcoin(opts.fetch(:fee, 0))
        dest_wallet = normalize_wallet(opts.fetch(:to))

        if source_wallet.balance(symbol) < amount_btc + fee
          raise "Wallet only has #{source_wallet.balance(symbol).to_s('F')} " \
                "#{symbol}, " \
                "cannot move #{amount_btc.to_s('F')} + #{fee.to_s('F')}."
        end

        source_wallet.add_balance symbol, -(amount_btc + fee)
        dest_wallet.add_balance symbol, amount_btc

        add_fee_if_needed(date, symbol, fee)
      end

      def purchase_with_crypto(date, symbol, amount_crypto, market_value_usd,
                               wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount_crypto = Bitcoin.normalize_positive_bitcoin(amount_crypto)
        market_value_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(market_value_usd)
        wallet = normalize_wallet(wallet)

        check_opts opts, [:for, :fee, :txid]

        fee = Bitcoin.normalize_nonnegative_bitcoin(opts.fetch(:fee, 0))

        if wallet.balance(symbol) < amount_crypto + fee
          raise "Wallet only has #{wallet.balance(symbol)} #{symbol}, cannot spend #{amount_crypto} + #{fee}."
        end

        wallet.add_balance symbol, -(amount_crypto + fee)

        add_fee_if_needed(date, symbol, fee)

        transaction = Transaction.new(date, :sale, amount_crypto, market_value_usd)
        lot_tracker(symbol).add_transaction(transaction)
      end

      def income_crypto(date, symbol, amount_crypto, market_value_usd, wallet, opts = {})
        date = DegUsaTax.normalize_date(date)
        amount_crypto = Bitcoin.normalize_positive_bitcoin(amount_crypto)
        market_value_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(market_value_usd)
        wallet = normalize_wallet(wallet)

        wallet.add_balance symbol, amount_crypto

        check_opts opts, [:for, :txid, :desc]

        desc = opts.fetch(:desc) { "income #{symbol}" }
        record_income(date, market_value_usd, desc)

        transaction = Transaction.new(date, :purchase, amount_crypto, market_value_usd)
        lot_tracker(symbol).add_transaction transaction
      end

      # Note: Would be nice to have an option for excluding certain wallets if
      # those wallets don't let you access the forked coins.
      def currency_fork(date, symbol_orig, symbol_fork, opts = {})
        date = DegUsaTax.normalize_date(date)
        check_opts opts, [:initial_usd_price]
        unit_price_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(
          opts.fetch(:initial_usd_price))

        # Update the balances of wallets holding the original currency.
        @wallets.each_value do |wallet|
          balance_orig = wallet.balance(symbol_orig)
          next if balance_orig.zero?

          # Assume this is a 1 to 1 fork.
          balance_fork = balance_orig

          # Calculate income, rounded to nearest penny.
          income_usd = (unit_price_usd * balance_fork).round(2)

          desc = "fork: #{symbol_orig}->#{symbol_fork}, #{wallet.name}"

          income_crypto(date, symbol_fork, balance_fork, income_usd,
                        wallet, desc: desc)
        end
      end

      def assert_balance(wallet, balance_map)
        if balance_map.is_a?(String) || balance_map.is_a?(Numeric)
          balance_map = { btc: balance_map }
        end
        wallet = normalize_wallet(wallet)
        balance_map.each do |symbol, expected|
          expected = Bitcoin.normalize_nonnegative_bitcoin(expected)
          actual = wallet.balance(symbol)
          if expected != actual
            diff = actual - expected
            raise 'Expected %s %s balance of %s, got %s.  Difference: %s' %
                  [wallet.name, symbol, expected.to_s('F'),
                   actual.to_s('F'), diff.to_s('F')]
          end
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

      def add_fee_if_needed(date, symbol, fee)
        if !fee.zero?
          transaction = Transaction.new(date, :donation, fee, 0)
          lot_tracker(symbol).add_transaction(transaction)
        end
      end
    end
  end
end
