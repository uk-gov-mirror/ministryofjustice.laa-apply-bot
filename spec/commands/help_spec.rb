require 'spec_helper'

describe SlackRubyBot::Commands::Help, :vcr do
  before do
    stub_request(:post, %r{\Ahttps://slack.com/api/conversations.info\z}).to_return(status: 200, body: expected_body)
  end
  let(:expected_body) do
    {
      'ok': true,
      'channel': {
        name: channel
      }
    }.to_json
  end
  let(:channel) { 'channel' }
  let(:user_input) { "#{SlackRubyBot.config.user} help" }
  let(:expected_response) do
    "*Weather Bot* - This bot tells you the weather.\n"\
    "\n*Commands:*\n*clouds* - Tells you how many clouds there're above you."\
    "\n*command_without_description*\n*What's the weather in <city>?* - Tells you the weather in a <city>.\n"\
    "*LAA Apply Bot* - This bot assists the LAA Apply team to administer their applications\n"\
    "\n*Commands:*"\
    "\n*add users* - `@apply-bot add users <comma separated names>`"\
    "\n*ages* - `@apply-bot ages`"\
    "\n*details* - `@apply-bot <application> details <environment>` e.g. `@apply-bot cfe details staging`"\
    "\n*run tests* - `@apply-bot run tests`"\
    "\n*uat urls* - `@apply-bot uat urls`"\
    "\n*uat url* - `@apply-bot uat url <branch> e.g. @apply-bot uat url ap-999`"\
    "\n*helm* - `@apply-bot helm <instruction>` e.g. `@apply-bot helm list`"\
    "\n*github* - `@apply-bot github <instruction>` e.g. `@apply-bot github link <your github name>`"\
    "\n*2fa* - `@apply-bot 2fa <instruction>` e.g. `@apply-bot 2fa setup`\n"\
    "\nFor full description of the command use: *help <command>*\n"
  end
  # TODO: find out why the ruby-slack-bot is inserting thw weather bot output into the test response!

  it 'returns the expected message' do
    expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
  end

  context 'when passed an explicit command' do
    let(:user_input) { "#{SlackRubyBot.config.user} help details" }
    let(:expected_response) do
      "*details* - `@apply-bot <application> details <environment>` e.g. `@apply-bot cfe details staging`\n"\
      "\nShows the ping details page for the selected application and non-uat environments, "\
      'e.g.  `@apply-bot apply details staging` or `@apply-bot cfe details production`'
    end

    it 'returns the expected message' do
      expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
    end
  end

  context 'when in a public channel' do
    let(:expected_response) do
      <<~ADDUSER.chomp
        *add users* - `@apply-bot add users <comma separated names>`

        Generates a portal user script in the #{ENV['USER_OUTPUT_CHANNEL']} channel regardless of where you ask
        e.g. `@applybot add user BENREID` or `@applybot add users benreid, NEETADESOR`
      ADDUSER
    end
    let(:channel) { 'shared_channel' }
    it 'returns the expected message' do
      expect(message: user_input, channel: channel).to respond_with_slack_message(expected_response)
    end
  end
end
