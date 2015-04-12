require_relative 'spec_helper'

describe DegUsaTax::FifoLotFinder do
  def bl(transactions)
    lots = described_class.break_into_lots(transactions)
    lots.map do |lot|
      [ lot.amount, lot.purchase, lot.sale ]
    end
  end

  specify 'given an empty array, returns an emtpy array' do
    expect(bl([])).to eq []
  end

  specify 'given one purchase, returns an empty array' do
    txs = [
      Transaction.new(Date.new(2000), :purchase, 1, 4)
    ]
    expect(bl(txs)).to eq []
  end

  specify 'given one purchase, and a smaller sale, returns a lot' do
    txs = [
      Transaction.new(Date.new(2001), :purchase, 2, 4),
      Transaction.new(Date.new(2002), :sale, 1, 5),
    ]
    expect(bl(txs)).to eq [
      [1, txs[0], txs[1]]
    ]
  end

  specify 'given one purchase, and a larger sale, raises an error' do
    txs = [
      Transaction.new(Date.new(2003), :purchase, 2, 4),
      Transaction.new(Date.new(2004), :sale, 3, 5),
    ]
    expect { bl(txs) }.to raise_error 'unmatched sale'
  end

  specify 'given two purchases, and a small sale. returns one lot' do
    txs = [
      Transaction.new(Date.new(2005), :purchase, 2, 4),
      Transaction.new(Date.new(2006), :purchase, 2, 4),
      Transaction.new(Date.new(2007), :sale, 1, 5),
    ]
    expect(bl(txs)).to eq [
      [1, txs[0], txs[2]],
    ]
  end

  specify 'given two purchases, and a big sale, returns two lots' do
    txs = [
      Transaction.new(Date.new(2008), :purchase, 2, 4),
      Transaction.new(Date.new(2009), :purchase, 2, 4),
      Transaction.new(Date.new(2010), :sale, 3, 5),
    ]
    expect(bl(txs)).to eq [
      [2, txs[0], txs[2]],
      [1, txs[1], txs[2]],
    ]
  end

  specify 'given two purchases and two sales' do
    txs = [
      Transaction.new(Date.new(2011), :purchase, 2, 4),
      Transaction.new(Date.new(2012), :sale, 1, 5),
      Transaction.new(Date.new(2013), :sale, 1, 5),
    ]
    expect(bl(txs)).to eq [
      [1, txs[0], txs[1]],
      [1, txs[0], txs[2]],
    ]
  end

  specify 'given transactions with out-of-order dates, raises an error' do
    txs = [
      Transaction.new(Date.new(2015), :purchase, 2, 4),
      Transaction.new(Date.new(2014), :purchase, 2, 4),
    ]
    expect { bl(txs) }.to raise_error \
      ArgumentError, 'transaction dates are out of order: 2015-01-01 followed by 2014-01-01'
  end

  specify 'given a purchase and a donation' do
    txs = [
      Transaction.new(Date.new(2016), :purchase, 2, 4),
      Transaction.new(Date.new(2017), :donation, 1, 0),
    ]
    expect(bl(txs)).to eq [
      [1, txs[0], txs[1]]
    ]
  end
end
