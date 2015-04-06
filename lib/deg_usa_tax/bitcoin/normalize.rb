module DegUsaTax
  module Bitcoin
    def self.normalize_positive_bitcoin(num)
      num = DegUsaTax.normalize_positive_bigdecimal(num)

      if num.round(8) != num
        fail ArgumentError, "bitcoin quantity with more than " \
          "8 digits after the decimal point: #{num.to_s('F')}"
      end

      num
    end
  end
end
