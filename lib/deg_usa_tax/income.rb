module DegUsaTax
  class Income
    attr_reader :date, :amount_usd, :desc

    def initialize(date, amount_usd, desc)
      @date = DegUsaTax.normalize_date(date)
      @amount_usd = DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal(amount_usd)
      @desc = desc
    end
  end
end
