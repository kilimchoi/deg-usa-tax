require_relative 'spec_helper'

describe DegUsaTax do
  describe 'normalize_date' do
    it 'accepts a Date' do
      date = Date.new(2002)
      expect(DegUsaTax.normalize_date(date)).to eql date
    end

    it 'rejects junk' do
      expect { DegUsaTax.normalize_date(44) }.to \
        raise_error ArgumentError, 'expected a Date, got 44'
    end
  end

  describe 'normalize_bigdecimal' do
    it 'converts an Integer to BigDecimal' do
      expect(DegUsaTax.normalize_bigdecimal(1)).to eql BigDecimal(1)
    end

    it 'accepts a BigDecimal' do
      expect(DegUsaTax.normalize_bigdecimal(BigDecimal(2))).to eql BigDecimal(2)
    end

    it 'rejects floats because you should never use a float for accounting' do
      expect { DegUsaTax.normalize_bigdecimal(1.0) }.to \
        raise_error ArgumentError, 'expected Integer or BigDecimal, got Float (1.0)'
    end
  end

  describe 'normalize_positive_bigdecimal' do
    it 'rejects 0' do
      expect { DegUsaTax.normalize_positive_bigdecimal(0) }.to \
        raise_error ArgumentError, 'expected positive number, got 0.0'
    end

    it 'rejects -1' do
      expect { DegUsaTax.normalize_positive_bigdecimal(-1) }.to \
        raise_error ArgumentError, 'expected positive number, got -1.0'
    end

    it 'converts 1 to a BigDecimal' do
      expect(DegUsaTax.normalize_positive_bigdecimal(1)).to eql BigDecimal(1)
    end
  end
end
