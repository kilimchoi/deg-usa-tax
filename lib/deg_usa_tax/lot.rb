# TODO: move into DegUsaTax module
class Lot
  attr_reader :amount, :purchase, :sale, :purchase_price, :sale_price

  def initialize(amount, purchase, sale, purchase_price = nil, sale_price = nil)
    @amount = DegUsaTax.normalize_positive_bigdecimal(amount)
    @purchase = DegUsaTax.normalize_transaction(purchase)
    @sale = DegUsaTax.normalize_transaction(sale)

    if purchase_price
      @purchase_price = DegUsaTax.normalize_positive_bigdecimal(purchase_price)
    end

    if sale_price
      @sale_price = DegUsaTax.normalize_nonnegative_bigdecimal(sale_price)
    end
  end

  def copy_and_change(opts)
    purchase_price = opts.fetch(:purchase_price) { self.purchase_price }
    sale_price = opts.fetch(:sale_price) { self.sale_price }
    Lot.new(amount, purchase, sale, purchase_price, sale_price)
  end
end
