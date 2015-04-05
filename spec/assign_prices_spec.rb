require_relative 'spec_helper'

describe 'assign_prices' do
  it 'given an empty/zero inputs, returns an empty array' do
    expect(DegUsaTax.assign_prices(0, 1, [])).to eq []
  end

  specify 'a single weight' do
    expect(DegUsaTax.assign_prices(4, 1, [1])).to eq [4]
  end

  specify 'a single, incomplete weight' do
    expect(DegUsaTax.assign_prices(6, 3, [2])).to eq [4]
  end

  specify 'two equal weights' do
    expect(DegUsaTax.assign_prices(4, 2, [1, 1])).to eq [2, 2]
  end

  specify 'two unequal weights' do
    expect(DegUsaTax.assign_prices(1, 100, [55, 45])).to eq [BigDecimal('0.55'), BigDecimal('0.45')]
  end

  specify 'three equal weights' do
    expect(DegUsaTax.assign_prices(1, 3, [1, 1, 1])).to eq [
      BigDecimal('0.33'),
      BigDecimal('0.34'),
      BigDecimal('0.33')
    ]
  end

  specify 'rounding errors bigger than the typical share' do
    expect(DegUsaTax.assign_prices(BigDecimal('0.15'), 10, [1] * 10)).to \
      eq [BigDecimal('0.02'), BigDecimal('0.01')] * 5
  end

  specify '0.17 divided 6 ways' do
    expect(DegUsaTax.assign_prices(BigDecimal('0.17'), 6, [1] * 6)).to eq [
      BigDecimal('0.03'),
      BigDecimal('0.03'),
      BigDecimal('0.03'),
      BigDecimal('0.03'),
      BigDecimal('0.03'),
      BigDecimal('0.02'),
    ]
  end
end
