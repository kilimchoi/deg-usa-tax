require 'date'

class Transaction
  attr_reader :date, :type, :amount, :price

  def initialize(date, type, amount, price)
    @date = DegUsaTax.normalize_date(date)
    @type = normalize_type(type)
    @amount = amount
    @price = price
  end

  private
  def normalize_type(type)
    if ![:purchase, :sale].include?(type)
      raise ArgumentError, "expected :purchase or :sale, got #{type.inspect}"
    end
    type
  end
end
