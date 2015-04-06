require 'spec_helper'

describe DegUsaTax::Bitcoin::History do
  let(:lot_tracker) do
    double('lot_tracker')
  end

  subject(:history) do
    described_class.new lot_tracker: lot_tracker
  end

  it 'can hold wallets' do
    history.create_wallet(:coinbase, off_chain: true)
    expect(history.wallet(:coinbase).name).to eq :coinbase
    expect(history.wallet(:coinbase).off_chain?).to eq true
  end
end
