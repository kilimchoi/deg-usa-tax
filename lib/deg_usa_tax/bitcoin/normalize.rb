module DegUsaTax
  module Bitcoin
    def self.normalize_bitcoin(num)
      num = DegUsaTax.normalize_bigdecimal(num)

      if num.round(8) != num
        fail ArgumentError, "bitcoin quantity with more than " \
          "8 digits after the decimal point: #{num.to_s('F')}"
      end

      num
    end

    def self.normalize_nonnegative_bitcoin(num)
      num = normalize_bitcoin(num)
      if num < 0
        fail ArgumentError, "expected non-negative bitcoin quantity, got #{num.to_s('F')}"
      end
      num
    end

    def self.normalize_positive_bitcoin(num)
      num = normalize_bitcoin(num)
      if num <= 0
        fail ArgumentError, "expected positive bitcoin quantity, got #{num.to_s('F')}"
      end
      num
    end
  end
end
