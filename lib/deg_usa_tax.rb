require 'date'
require 'bigdecimal'

require 'deg_usa_tax/transaction'
require 'deg_usa_tax/lot'
require 'deg_usa_tax/fifo_lot_finder'
require 'deg_usa_tax/assign_prices'
require 'deg_usa_tax/lot_pricer'
require 'deg_usa_tax/lot_index'
require 'deg_usa_tax/option_checker'

require 'deg_usa_tax/bitcoin/normalize'
require 'deg_usa_tax/bitcoin/history'
require 'deg_usa_tax/bitcoin/wallet'

module DegUsaTax
  def self.normalize_date(v)
    case v
    when Date
      v
    when String
      Date.parse(v)
    else
      raise ArgumentError, "expected a date, got #{v.inspect}"
    end
  end

  def self.normalize_bigdecimal(num)
    if num.is_a?(Float)
      fail ArgumentError, "expected Integer or BigDecimal, got Float (#{num})"
    end
    BigDecimal(num)
  end

  def self.normalize_positive_bigdecimal(num)
    num = normalize_bigdecimal(num)
    if num <= 0
      fail ArgumentError, "expected positive number, got #{num.to_s('F')}"
    end
    num
  end

  def self.normalize_nonnegative_bigdecimal(num)
    num = normalize_bigdecimal(num)
    if num < 0
      fail ArgumentError, "expected non-negative number, got #{num.to_s('F')}"
    end
    num
  end

  def self.normalize_nonnegative_wholepenny_bigdecimal(num)
    num = normalize_nonnegative_bigdecimal(num)
    if num != num.round(2)
      fail ArgumentError, "expected whole pennies, got 1.111"
    end
    num
  end

  def self.normalize_transaction(transaction)
    if !transaction.is_a?(Transaction)
      fail ArgumentError, "expected a Transaction, got #{transaction.inspect}"
    end
    transaction
  end
end
