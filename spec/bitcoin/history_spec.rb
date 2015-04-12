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
      expect(@tx.type).to eql :purchase
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

    it 'removes the fee and donation from the wallet' do
      expect(history.wallet(:brain).balance).to eq BigDecimal('0.9985')
    end

    it 'adds a donation transaction' do
      expect(@tx.date).to eq Date.new(2014)
      expect(@tx.type).to eq :donation
      expect(@tx.amount).to eq BigDecimal('0.002')
      expect(@tx.price).to eq BigDecimal('0')
    end
  end

  describe 'move_btc' do
    before do
      allow(lot_tracker).to receive(:add_transaction) { |tx| @tx = tx }
      history.create_wallet :brain
      history.create_wallet :coinbase, off_chain: true
      history.buy_btc_with_usd Date.new(2013), '1.0', '120.00', :coinbase
      history.buy_btc_with_usd Date.new(2013), '0.01', '1.00', :brain
    end

    context 'normal case' do
      before do
        history.move_btc Date.new(2014), '0.6', :coinbase, to: :brain, fee: '0.0001',
          txid: '1e43f56893e1c2edac86ca25ce46862dd5e664849aa866cdad5a92e4c562a86e'
      end

      it 'adds a donation transaction for the fee' do
        expect(@tx.date).to eq Date.new(2014)
        expect(@tx.type).to eq :donation
        expect(@tx.amount).to eq BigDecimal('0.0001')
        expect(@tx.price).to eq 0
      end

      it 'deducts the amount and fee from the source wallet' do
        expect(history.wallet(:coinbase).balance).to eq BigDecimal('0.3999')
      end

      it 'adds the amount to the destination wallet' do
        expect(history.wallet(:brain).balance).to eq BigDecimal('0.61')
      end
    end

    context 'no fee' do
      before do
        @tx = nil
        history.move_btc Date.new(2014), '0.6', :coinbase, to: :brain,
          txid: '1e43f56893e1c2edac86ca25ce46862dd5e664849aa866cdad5a92e4c562a86e'
      end

      it 'adds no transaction' do
        expect(@tx).to eq nil
      end
    end

    context 'not enough money at source' do
      it 'raises an error' do
        expect do
          history.move_btc Date.new(2014), '0.6', :brain, to: :coinbase, fee: '0.0001',
           txid: '1e43f56893e1c2edac86ca25ce46862dd5e664849aa866cdad5a92e4c562a86e'
        end.to raise_error "Wallet only has 0.01, cannot move 0.6 + 0.0001."
      end
    end
  end

  describe 'purchase_with_btc' do
    before do
      @txs = []
      allow(lot_tracker).to receive(:add_transaction) { |tx| @txs << tx }
      history.create_wallet :brain
      history.buy_btc_with_usd Date.new(2013), '1.0', '120.00', :brain,
        txid: '1e43f56893e1c2edac86ca25ce46862dd5e664849aa866cdad5a92e4c562a86e'
      @txs = []
      history.purchase_with_btc Date.new(2014), '0.01', '2.04', :brain, fee: '0.0005'
    end

    it 'deducts the amount and fee from the wallet' do
      expect(history.wallet(:brain).balance).to eq BigDecimal('0.9895')
    end

    it 'makes a transaction for the fee first' do
      tx = @txs[0]
      expect(tx.date).to eq Date.new(2014)
      expect(tx.type).to eq :donation
      expect(tx.amount).to eq BigDecimal('0.0005')
      expect(tx.price).to eq 0
    end

    it 'make a transaction for the purchase second' do
      tx = @txs[1]
      expect(tx.date).to eq Date.new(2014)
      expect(tx.type).to eq :sale
      expect(tx.amount).to eq BigDecimal('0.01')
      expect(tx.price).to eq BigDecimal('2.04')
    end
  end
end
