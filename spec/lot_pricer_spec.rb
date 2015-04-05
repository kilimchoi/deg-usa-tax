require_relative 'spec_helper'

describe DegUsaTax::LotPricer do
  def lp(lots)
    out_lots = described_class.price_lots(lots)

    # Basic checks to make sure that it actually assined prices
    # and didn't change anything it wasn't supposed to.
    fail if lots.size != out_lots.size
    lots.zip(out_lots) do |inlot, outlot|
      fail if inlot.amount != outlot.amount
      fail if inlot.purchase != outlot.purchase
      fail if inlot.sale != outlot.sale
      fail if !outlot.purchase_price
      fail if !outlot.sale_price
    end

    out_lots.map do |lot|
      [lot.purchase_price, lot.sale_price]
    end
  end

  it 'returns [] when given []' do
    expect(lp([])).to eq []
  end

  it 'handles a simple case with one purchase and one sale' do
    txs = [
      Transaction.new(Date.new(2000), :purchase, 20, 6),
      Transaction.new(Date.new(2001), :sale, 10, 4),
    ]
    lots = [
      Lot.new(10, txs[0], txs[1]),
    ]
    expect(lp(lots)).to eq [[3, 4]]
  end
end
