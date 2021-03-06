module DegUsaTax
  class FifoLotFinder
    attr_reader :lots

    def initialize
      @lots = []
      @unmatched_purchase_infos = []
      @last_transaction_date = nil
    end

    def self.break_into_lots(transactions)
      lf = new
      transactions.each do |transaction|
        lf.add_transaction transaction
      end
      lf.lots
    end

    def add_transaction(transaction)
      handle_transaction_date(transaction.date)

      case transaction.type
      when :purchase
        add_purchase(transaction)
      when :sale, :donation
        add_sale_or_donation(transaction)
      else
        raise "Unrecognized transaction type: #{transaction.type}"
      end
    end

    private

    def add_purchase(purchase)
      @unmatched_purchase_infos << {
        transaction: purchase,
        unaccounted_amount: purchase.amount
      }
    end

    def add_sale_or_donation(sale)
      unaccounted_amount = sale.amount
      while unaccounted_amount > 0
        purchase_info = @unmatched_purchase_infos.first
        raise 'unmatched sale' if purchase_info.nil?

        purchase = purchase_info[:transaction]

        amount = [unaccounted_amount, purchase.amount].min
        lots << Lot.new(amount, purchase, sale)

        unaccounted_amount -= amount
        purchase_info[:unaccounted_amount] -= amount
        if purchase_info[:unaccounted_amount].zero?
          @unmatched_purchase_infos.shift
        end
      end
    end

    def handle_transaction_date(date)
      if @last_transaction_date && date < @last_transaction_date
        raise ArgumentError, 'transaction dates are out of order: ' \
          "#{@last_transaction_date} followed by #{date}"
      end
      @last_transaction_date = date
    end
  end
end
