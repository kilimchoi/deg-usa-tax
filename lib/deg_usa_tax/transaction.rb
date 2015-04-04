require 'date'

class Transaction
  attr_reader :date, :type, :amount, :unit_price

  def initialize(date, type, amount, unit_price)
    @date = date
    @type = type
    @amount = amount
    @unit_price = unit_price
  end
end
