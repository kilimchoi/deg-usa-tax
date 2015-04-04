require_relative 'spec_helper'

describe 'break_into_lots' do
  def bl(transactions)
    break_into_lots(transactions).map do |lot|
      [ lot.amount, lot.purchase, lot.sale ]
    end
  end

  specify 'given an empty array, returns an emtpy array' do
    expect(break_into_lots([])).to eq []
  end

  specify 'given one purchase, returns an empty array' do
    txs = [
      Transaction.new(nil, :purchase, 1, 4)
    ]
    expect(break_into_lots(txs)).to eq []
  end

  specify 'given one purchase, and a smaller sale, returns a lot' do
    txs = [
      Transaction.new(nil, :purchase, 2, 4),
      Transaction.new(nil, :sale, 1, 5),
    ]
    expect(bl(txs)).to eq [
      [1, txs[0], txs[1]]
    ]
  end

  specify 'given one purchase, and a larger sale, raises an error' do
    txs = [
      Transaction.new(nil, :purchase, 2, 4),
      Transaction.new(nil, :sale, 3, 5),
    ]
    expect { bl(txs) }.to raise_error 'unmatched sale'
  end

  specify 'given two purchases, and a small sale. returns one lot' do
    txs = [
      Transaction.new(nil, :purchase, 2, 4),
      Transaction.new(nil, :purchase, 2, 4),
      Transaction.new(nil, :sale, 1, 5),
    ]
    expect(bl(txs)).to eq [
      [1, txs[0], txs[2]],
    ]
  end

  specify 'given two purchases, and a big sale, returns two lots' do
    txs = [
      Transaction.new(nil, :purchase, 2, 4),
      Transaction.new(nil, :purchase, 2, 4),
      Transaction.new(nil, :sale, 3, 5),
    ]
    expect(bl(txs)).to eq [
      [2, txs[0], txs[2]],
      [1, txs[1], txs[2]],
    ]
  end

  specify 'given two purchases and two sales' do
    txs = [
      Transaction.new(Date.new(2012), :purchase, 2, 4),
      Transaction.new(Date.new(2013), :sale, 1, 5),
      Transaction.new(Date.new(2014), :sale, 1, 5),
    ]
    expect(bl(txs)).to eq [
      [1, txs[0], txs[1]],
      [1, txs[0], txs[2]],
    ]
  end
end
