require 'spec_helper'

RSpec.describe Helm::Delete do
  describe '#call' do
    subject(:call) { described_class.call('ap1234') }
    before { allow(described_class).to receive(:`).with(/helm delete.*/).and_return(response) }
    let(:response) { 'release "ap1234" uninstalled' }

    it { expect(subject).to eql(true) }
  end
end
