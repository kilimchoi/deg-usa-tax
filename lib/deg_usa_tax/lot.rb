class Lot
  attr_reader :amount, :purchase, :sale

  def initialize(amount, purchase, sale)
    @amount = amount
    @purchase = purchase
    @sale = sale
  end
end
