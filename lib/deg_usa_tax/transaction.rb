# TODO: move into DegUsaTax module
class Transaction
  attr_reader :date, :type, :amount, :price

  def initialize(date, type, amount, price)
    @date = DegUsaTax.normalize_date(date)
    @type = normalize_type(type)
    @amount = DegUsaTax.normalize_positive_bigdecimal(amount)
    @price = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(price)
  end

  private

  def normalize_type(type)
    if ![:purchase, :sale, :donation].include?(type)
      raise ArgumentError, "expected :purchase, :sale, or :donation, got #{type.inspect}"
    end
    type
  end
end
