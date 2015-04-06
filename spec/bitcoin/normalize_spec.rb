require 'spec_helper'

describe DegUsaTax::Bitcoin do
  describe 'normalize_positive_bitcoin' do
    it 'accepts bigdecimals with up to 8 digits after the point' do
      expect(described_class.normalize_positive_bitcoin('1.12345678')).to \
        eql BigDecimal('1.12345678')
    end

    it 'rejects bigdecimals with more than 8 digits after the point' do
      expect { described_class.normalize_positive_bitcoin('1.123456789') }.to \
        raise_error ArgumentError, 'bitcoin quantity with more than ' \
        '8 digits after the decimal point: 1.123456789'
    end
  end
end
