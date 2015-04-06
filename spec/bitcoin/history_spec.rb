require 'spec_helper'

describe DegUsaTax::Bitcoin::History do
  let(:lot_tracker) do
    double('lot_tracker')
  end

  subject(:history) do
    described_class.new lot_tracker: lot_tracker
  end

  describe 'create_wallet' do
    before do
      history.create_wallet(:coinbase, off_chain: true)
    end

    it 'uses the right name' do
      expect(history.wallet(:coinbase).name).to eq :coinbase
    end

    it 'recognizes the off_chain parameter' do
      expect(history.wallet(:coinbase).off_chain?).to eq true
    end

    it 'make the wallet have an initial balance of 0' do
      expect(history.wallet(:coinbase).balance).to eq 0
    end
  end

  describe 'buy_btc_with_usd' do
    before do
      allow(lot_tracker).to receive(:add_transaction) { |tx| @tx = tx }
      history.create_wallet :brain
      history.buy_btc_with_usd Date.new(2013), '1.0005', '120.00', :brain,
        txid: '1e43f56893e1c2edac86ca25ce46862dd5e664849aa866cdad5a92e4c562a86e'
    end

    it 'adds the BTC to the wallet\'s balance' do
      expect(history.wallet(:brain).balance).to eq BigDecimal('1.0005')
    end

    it 'adds a transaction with the correct fields to the lot tracker' do
      expect(@tx.date).to eql Date.new(2013)
      expect(@tx.amount).to eql BigDecimal('1.0005')
      expect(@tx.price).to eql BigDecimal('120.00')
    end
  end

  describe 'donate_btc' do
    before do
      allow(lot_tracker).to receive(:add_transaction) { |tx| @tx = tx }
      history.create_wallet :brain
      history.buy_btc_with_usd Date.new(2013), '1.0005', '120.00', :brain,
        txid: '1e43f56893e1c2edac86ca25ce46862dd5e664849aa866cdad5a92e4c562a86e'
      history.donate_btc Date.new(2014), '0.0015', :brain, fee: '0.0005'
    end
  end
end
