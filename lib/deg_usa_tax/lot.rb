class Lot
  attr_reader :amount, :purchase, :sale, :purchase_price, :sale_price

  def initialize(amount, purchase, sale, purchase_price = nil, sale_price = nil)
    @amount = DegUsaTax.normalize_positive_bigdecimal(amount)
    @purchase = DegUsaTax.normalize_transaction(purchase)
    @sale = DegUsaTax.normalize_transaction(sale)

    if @purchase_price
      @purchase_price = DegUsaTax.normalize_positive_bigdecimal(purchase_price)
    end

    if @sale_price
      @sale_price = DegUsaTax.normalize_positive_bigdecimal(sale_price)
    end
  end
end
