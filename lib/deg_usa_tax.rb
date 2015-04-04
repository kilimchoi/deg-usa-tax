require 'date'
require 'bigdecimal'
require 'deg_usa_tax/transaction'
require 'deg_usa_tax/lot'
require 'deg_usa_tax/fifo_lot_finder'

module DegUsaTax
  def self.normalize_date(date)
    if !date.is_a?(Date)
      raise ArgumentError, "expected a Date, got #{date.inspect}"
    end
    date
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
end
