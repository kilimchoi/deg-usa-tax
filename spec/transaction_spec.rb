require_relative 'spec_helper'

describe Transaction do
  subject(:tx) do
    Transaction.new(Date.new(2013), :purchase, 1, 4)
  end

  it 'holds the date' do
    expect(tx.date).to eq Date.new(2013)
  end

  it 'holds the type' do
    expect(tx.type).to eq :purchase
  end

  it 'rejects bad types' do
    expect { Transaction.new(Date.new(2000), 44, 1, 4) }.to \
      raise_error ArgumentError, 'expected :purchase, :sale, or :donation, got 44'
  end

  it 'holds the amount' do
    expect(tx.amount).to eq 1
  end

  it 'holds the unit_price' do
    expect(tx.price).to eq 4
  end
end

