class Lot
  attr_reader :amount, :purchase, :sale, :purchase_price, :sale_price

  def initialize(amount, purchase, sale, purchase_price = nil, sale_price = nil)
    @amount = amount
    @purchase = purchase
    @sale = sale
    @purchase_price = purchase_price
    @sale_price = sale_price
  end
end
