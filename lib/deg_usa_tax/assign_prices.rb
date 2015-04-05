module DegUsaTax
  def self.assign_prices(total_price, weights)
    total_price = DegUsaTax.normalize_bigdecimal(total_price)
    if weights.empty?
      if !total_price.zero?
        raise ArgumentError, 'impossible to assign prices for empty ' \
          'list of weights since price is non-zero'
      end
      return []
    end
    weights = weights.map &DegUsaTax.method(:normalize_positive_bigdecimal)

    total_weight = weights.inject(:+)

    prices = weights.map do |weight|
      (total_price * weight / total_weight).round(2)
    end

    # Rounding error happens during the division above and also when
    # we call 'round'.  We correct for it here.
    rounding_error = prices.inject(:+) - total_price
    prices[-1] -= rounding_error

    # Double-check that the sub-prices all add up to the total price.
    if prices.inject(:+) != total_price
      raise 'failed to fix rounding errors'
    end

    prices
  end
end
