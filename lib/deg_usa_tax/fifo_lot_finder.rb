module DegUsaTax
  class FifoLotFinder
    attr_reader :lots

    def initialize
      @lots = []
      @unmatched_purchase_infos = []
      @last_transaction_date = nil
    end

    def break_into_lots(transactions)
      transactions.each do |transaction|
        add_transaction transaction
      end
      lots
    end

    def add_transaction(transaction)
      case transaction.type
      when :purchase
        @unmatched_purchase_infos << {
          transaction: transaction,
          unaccounted_amount: transaction.amount
        }
      when :sale
        sale = transaction
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
    end
  end
end
