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
end
