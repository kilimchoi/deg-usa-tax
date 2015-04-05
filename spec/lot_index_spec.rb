require 'spec_helper'

describe DegUsaTax::LotIndex do
  let(:txs) do
    [
      Transaction.new(Date.new(2000), :purchase, 2, 4),
      Transaction.new(Date.new(2001), :purchase, 2, 8),
      Transaction.new(Date.new(2002), :sale, 2, 8),
      Transaction.new(Date.new(2003), :sale, 2, 4),
    ]
  end

  let(:lots) do
    [
      Lot.new(1, txs[0], txs[2]),
      Lot.new(1, txs[1], txs[2]),
      Lot.new(1, txs[0], txs[3]),
      Lot.new(1, txs[1], txs[3]),
    ]
  end

  subject(:index) do
    described_class.new(lots)
  end

  describe 'each_purchase' do
    it 'iterates over each purchase' do
      expect(index.each_purchase.to_a).to eq txs[0, 2]
    end
  end

  describe 'each_sale' do
    it 'iterates over each sale' do
      expect(index.each_sale.to_a).to eq txs[2, 2]
    end
  end

  describe 'each_lot_for' do
    it 'works for purchases' do
      expect(index.each_lot_for(txs[0])).to eq [lots[0], lots[2]]
    end

    it 'works for purchases' do
      expect(index.each_lot_for(txs[3])).to eq [lots[2], lots[3]]
    end
  end
end
