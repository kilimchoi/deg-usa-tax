module DegUsaTax
  class LotIndex
    def initialize(lots)
      @lots = lots
      @purchases = lots.map do |lot|
        lot.purchase
      end.uniq

      @sales = lots.map do |lot|
        lot.sale
      end.uniq
    end

    def each_purchase(&proc)
      @purchases.each(&proc)
    end

    def each_sale(&proc)
      @sales.each(&proc)
    end

    def each_lot_for(transaction)
      @lots.select do |lot|
        lot.purchase == transaction || lot.sale == transaction
      end
    end
  end
end
