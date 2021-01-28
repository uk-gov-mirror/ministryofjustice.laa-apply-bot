require 'rspec'

RSpec.describe SlackApplybot::Commands::TwoFactorAuth do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.open\z}).to_return(status: 200, body: user_body)
  end
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel,
        is_im: is_direct_message?
      }
    }.to_json
  end
  let(:user_body) do
    {
      'ok': true,
      'channel': {
        id: 'A0000B1CDEF'
      }
    }.to_json
  end
  let(:channel) { 'channel' }
  let(:is_direct_message?) { false }

  describe '#setup' do
    let(:user_input) { "#{SlackRubyBot.config.user} 2fa setup" }
    let!(:client) { SlackRubyBot::App.new.send(:client) }
    let(:message_hook) { SlackRubyBot::Hooks::Message.new }
    let(:params) { Hashie::Mash.new(text: user_input, channel: channel, user: 'user') }

    context 'the user is in a direct message channel' do
      let(:is_direct_message?) { true }

      it 'starts typing' do
        expect(message: user_input, channel: 'channel').to start_typing(channel: 'channel')
      end
    end

    context 'the user is in a public, valid channel' do
      let(:expected_hash) do
        {
          channel: channel,
          text: "I've sent you a DM, we probably shouldn't be talking about this in public!"
        }
      end

      it 'responds with a warning message' do
        expect(client).to receive(:typing)
        expect(client).to receive(:say).with(expected_hash)
        message_hook.call(client, params)
      end
    end

    it_behaves_like 'the channel is invalid'
  end
end
