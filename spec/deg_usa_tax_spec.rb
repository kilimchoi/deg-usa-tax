require_relative 'spec_helper'

describe DegUsaTax do
  describe 'normalize_date' do
    it 'accepts a Date' do
      date = Date.new(2002)
      expect(DegUsaTax.normalize_date(date)).to eql date
    end

    it 'accepts a YYYY-MM-DD string' do
      expect(DegUsaTax.normalize_date('2006-03-04')).to eql \
        Date.new(2006, 3, 4)
    end

    it 'rejects junk' do
      expect { DegUsaTax.normalize_date(44) }.to \
        raise_error ArgumentError, 'expected a date, got 44'
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

  describe 'normalize_nonnegative_bigdecimal' do
    it 'accepts 0' do
      expect(DegUsaTax.normalize_nonnegative_bigdecimal(0)).to eq BigDecimal(0)
    end

    it 'rejects -1' do
      expect { DegUsaTax.normalize_nonnegative_bigdecimal(-1) }.to \
        raise_error ArgumentError, 'expected non-negative number, got -1.0'
    end

    it 'converts 1 to a BigDecimal' do
      expect(DegUsaTax.normalize_nonnegative_bigdecimal(1)).to eql BigDecimal(1)
    end
  end

  describe 'normalize_nonnegative_wholepenny_bigdecimal' do
    it 'accepts 1.11' do
      expect(DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal('1.11'))
        .to eql BigDecimal('1.11')
    end

    it 'rejects 1.111' do
      expect { DegUsaTax.normalize_nonnegative_wholepenny_bigdecimal('1.111') }
        .to raise_error ArgumentError, 'expected whole pennies, got 1.111'
    end
  end

  describe 'normalize_transaction' do
    it 'accepts a Transaction' do
      t = Transaction.new(Date.new(2000), :purchase, 1, 2)
      expect(DegUsaTax.normalize_transaction(t)).to eql t
    end

    it 'rejects junk' do
      expect { DegUsaTax.normalize_transaction(:x) }.to \
        raise_error ArgumentError, 'expected a Transaction, got :x'
    end
  end
end
