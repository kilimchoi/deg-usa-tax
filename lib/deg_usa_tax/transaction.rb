require 'date'

class Transaction
  attr_reader :date, :type, :amount, :price

  def initialize(date, type, amount, price)
    @date = date
    @type = type
    @amount = amount
    @price = price
  end
end
