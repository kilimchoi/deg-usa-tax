require_relative 'spec_helper'

describe 'assign_prices' do
  it 'given an empty array and 0 price, returns an empty array' do
    expect(DegUsaTax.assign_prices(0, [])).to eq []
  end

  it 'given an empty array and positive price, raises an error' do
    expect { DegUsaTax.assign_prices(1, []) }.to raise_error \
      ArgumentError, 'impossible to assign prices for empty ' \
      'list of weights since price is non-zero'
  end

  specify 'a single weight' do
    expect(DegUsaTax.assign_prices(4, [1])).to eq [4]
  end

  specify 'two equal weights' do
    expect(DegUsaTax.assign_prices(4, [1, 1])).to eq [2, 2]
  end

  specify 'two unequal weights' do
    expect(DegUsaTax.assign_prices(1, [55, 45])).to eq [BigDecimal('0.55'), BigDecimal('0.45')]
  end

  it 'avoids rounding errors by adjusting the last entry' do
    expect(DegUsaTax.assign_prices(1, [1, 1, 1])).to eq [
      BigDecimal('0.33'),
      BigDecimal('0.33'),
      BigDecimal('0.34')
    ]
  end
end
