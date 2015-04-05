module DegUsaTax
  module LotPricer
    def self.price_lots(input_lots)
      lot_index = LotIndex.new(input_lots)
      output_lots = input_lots.dup

      # Figure out purchase prices.
      lot_index.each_purchase do |purchase|
        lots = lot_index.each_lot_for(purchase).to_a
        weights = lots.map(&:amount)
        weights << purchase.amount - weights.inject(:+)

        prices = DegUsaTax.assign_prices(purchase.price, weights)
        prices.pop

        lots.zip(prices).each do |lot, purchase_price|
          index = input_lots.index(lot)
          output_lots[index] = output_lots[index].copy_and_change(purchase_price: purchase_price)
        end
      end

      # Figure out sale prices.
      lot_index.each_sale do |sale|
        lots = lot_index.each_lot_for(sale).to_a
        weights = lots.map(&:amount)
        weights << sale.amount - weights.inject(:+)

        prices = DegUsaTax.assign_prices(sale.price, weights)
        prices.pop

        lots.zip(prices).each do |lot, sale_price|
          index = input_lots.index(lot)
          output_lots[index] = output_lots[index].copy_and_change(sale_price: sale_price)
        end
      end

      output_lots
    end
  end
end
