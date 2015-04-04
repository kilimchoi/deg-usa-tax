module DegUsaTax
  class FifoLotFinder
    def initialize
      @lots = []
      @unmatched_purchase_infos = []
    end

    def break_into_lots(transactions)
      lots = []
      purchase_infos = []
      transactions.each do |transaction|
        if transaction.type == :purchase
          purchase_infos << { transaction: transaction,
                              unaccounted_amount: transaction.amount }
        elsif transaction.type == :sale
          sale = transaction
          unaccounted_amount = sale.amount
          while unaccounted_amount > 0
            purchase_info = purchase_infos.first
            if purchase_info.nil?
              raise 'unmatched sale'
            end
            purchase = purchase_info[:transaction]

            amount = [unaccounted_amount, purchase.amount].min
            lots << Lot.new(amount, purchase, sale)

            unaccounted_amount -= amount
            purchase_info[:unaccounted_amount] -= amount
            if purchase_info[:unaccounted_amount].zero?
              purchase_infos.shift
            end
          end
        end
      end
      lots
    end
  end
end
