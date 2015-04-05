require 'spec_helper'

describe Lot do
  let(:purchase) do
    Transaction.new(Date.new(2002), :purchase, 1, 4)
  end

  let(:sale) do
    Transaction.new(Date.new(2003), :sale, 2, 6)
  end

  let(:lot) do
    described_class.new(1, purchase, sale, 4, 3)
  end

  it 'holds the amount' do
    expect(lot.amount).to eq 1
  end

  it 'holds the purchase' do
    expect(lot.purchase).to eq purchase
  end

  it 'holds the sale' do
    expect(lot.sale).to eq sale
  end

  it 'holds the purchase price' do
    expect(lot.purchase_price).to eq 4
  end

  it 'holds the sale price' do
    expect(lot.sale_price).to eq 3
  end

  describe 'copy_and_change' do
    it 'can change the purchase_price' do
      lot2 = lot.copy_and_change(purchase_price: 10)
      expect(lot2.purchase_price).to eq 10
      expect(lot.purchase_price).to eq 4
    end

    it 'can change the sale_price' do
      lot2 = lot.copy_and_change(sale_price: 11)
      expect(lot2.sale_price).to eq 11
      expect(lot.sale_price).to eq 3
    end
  end
end
