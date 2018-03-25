require 'spec_helper'

describe DegUsaTax::Bitcoin::Wallet do
  subject(:wallet) do
    described_class.new(:bitcoin_android)
  end

  subject(:wallet_off_chain) do
    described_class.new(:coinbase, off_chain: true)
  end

  it 'has a name' do
    expect(wallet.name).to eq :bitcoin_android
  end

  it 'knows if it is on the blockchain' do
    expect(wallet).to_not be_off_chain
    expect(wallet_off_chain).to be_off_chain
  end

  it 'can hold Bitcoin addresses' do
    expect(wallet.addresses).to eq []
  end

  it 'can hold a balance for different currencies' do
    expect(wallet.balance(:btc)).to eq 0
    wallet.add_balance :btc, 5
    expect(wallet.balance(:btc)).to eq 5
    wallet.add_balance :btc, -1
    expect(wallet.balance(:btc)).to eq 4
    wallet.add_balance :bch, 3
    expect(wallet.balance(:btc)).to eq 4
    expect(wallet.balance(:bch)).to eq 3
  end
end
