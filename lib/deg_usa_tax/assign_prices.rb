module DegUsaTax
  # weights should be passed in chronological order so that
  # future tax returns are consistent with past ones
  def self.assign_prices(total_price, total_weight, weights)
    total_price = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(total_price)
    total_weight = DegUsaTax.normalize_positive_bigdecimal(total_weight)
    weights = weights.map &DegUsaTax.method(:normalize_nonnegative_bigdecimal)
    return [] if weights.empty?
    if weights.inject(:+) > total_weight
      fail ArgumentError, 'sum of weights is greater than total weight'
    end

    unaccounted_weight = total_weight
    unaccounted_price = total_price
    prices = weights.map do |weight|
      if unaccounted_weight.zero?
        price = unaccounted_price
      else
        price = (unaccounted_price * weight / unaccounted_weight).round(2)
      end

      unaccounted_weight -= weight
      unaccounted_price -= price

      price
    end

    # If all the weight is accounted for, double-check that the prices
    # add up to the total price.
    if unaccounted_weight.zero? && prices.inject(:+) != total_price
      raise 'failed to fix rounding errors'
    end

    # Check that no prices are negative. (but 0 is fine)
    if prices.any? { |p| p < 0 }
      raise 'negative price generated'
    end

    prices
  end
end
