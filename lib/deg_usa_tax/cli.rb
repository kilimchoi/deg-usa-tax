# TODO: organize this code better and add tests for it

require 'deg_usa_tax'

module DegUsaTax
  class CLI
    attr_reader :output, :error_output

    def initialize(args, output, error_output)
      @args = args
      @output = output
      @error_output = error_output
    end

    # Returns true for success, false for failure.
    def run
      if @args.empty?
        @error_output.puts "No arguments passed."
        return false
      end

      command = @args[0]
      case command
      when 'btc'
        return run_btc(@args[1, @args.length])
      else
        @error_output.puts "Unrecognized command #{command}"
        return false
      end
    end

    def run_btc(args)
      filename = args[0]
      if filename.nil?
        @error_output.puts "No filename given."
        return false
      end

      history = bitcoin_history_from_file(filename)

      report_wallets(history.wallets.values)

      raw_lots = history.lot_tracker.lots
      lots = LotPricer.price_lots(raw_lots)
      report_capital_gains(lots)

      true
    end

    def bitcoin_history_from_file(filename)
      history = Bitcoin::History.new

      # TODO: do this in a better way without instance_eval; we don't
      # get good stack traces from inside the eval in Ruby 2.1.5 and
      # we don't want the DSL to be able to access all the private
      # things inside the history object.
      history_data = File.read(filename)
      history.instance_eval history_data
      history
    end

    def report_wallets(wallets)
      wallets = wallets.sort_by { |w| -w.balance }
      total_bitcoin = wallets.map(&:balance).inject(0, :+)

      output.puts 'Your bitcoins:'
      wallets.each do |wallet|
        output.puts '%20s %13.8f' % [wallet.name, wallet.balance]
      end
      output.puts '%20s %13.8f' % ["TOTAL", total_bitcoin]
      output.puts
    end

    # Report capital gains in a format that lets them get reported easily
    # on form 8949.
    def report_capital_gains(lots)
      # filter out the donations
      lots = lots.reject { |l| l.sale.type == :donation }

      # put lots into buckets
      lots_by_bucket = lots.group_by { |l| lot_bucket(l) }

      lots_by_bucket.keys.sort.each do |bucket|
        output.puts "%4d, %s" % [bucket[0], %w{short long}[bucket[1]]]
        format = "%13.8f, %10s, %10s, %7.2f, %7.2f, %7.2f"
        total_format = "                                Total: %7.2f, %7.2f, %7.2f"
        total_purchase_price = 0
        total_sale_price = 0
        lots_by_bucket[bucket].each do |lot|
          total_purchase_price += lot.purchase_price
          total_sale_price += lot.sale_price
          puts format % [
            lot.amount,
            lot.purchase.date,
            lot.sale.date,
            lot.sale_price,
            lot.purchase_price,
            lot.sale_price - lot.purchase_price,
          ]
        end
        puts total_format % [
          total_purchase_price,
          total_sale_price,
          total_sale_price - total_purchase_price,
        ]
      end
    end

    def short_term?(lot)
      (lot.sale.date - lot.purchase.date).to_i < 365
    end

    def lot_bucket(lot)
      [tax_year(lot), short_term?(lot) ? 0 : 1].freeze
    end

    def tax_year(lot)
      lot.sale.date.year
    end

  end
end
