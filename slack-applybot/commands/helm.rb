module SlackApplybot
  module Commands
    class Helm < SlackRubyBot::Commands::Base
      require 'pry-byebug'
      command 'helm' do |client, data, match|
        @client = client
        @data = data
        @user = user
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        message = case match['expression']&.downcase
                  when /^delete/
                    process_delete(match)
                  when 'list'
                    result = "::Helm::#{match['expression'].capitalize}".constantize.call
                    "```#{result}```"
                  when 'tidy'
                    "::Helm::#{match['expression'].capitalize}".constantize.call
                  when nil
                    SlackRubyBot::Commands::Support::Help.instance.command_full_desc('helm')
                  else
                    "You called `helm` with `#{match['expression']}`. This is not supported."
                  end

        client.say(channel: data.channel, text: message)
      end

      class << self
        include ChannelValidity
        include TwoFactorAuth
        include UserCommand

        def process_delete(match)
          parts = match['expression'].split - ['delete']
          if parts.empty?
            'Unable to delete - insufficient data, please call as `helm delete name-of-release 000000`'
          elsif parts.count.eql?(1)
            'OTP password not provided, please call as `helm delete name-of-release 000000`'
          elsif validate_otp_part(parts[1])
            ::Helm::Delete.call(parts[0]) ? "#{parts[0]} deleted" : 'Unable to delete'
          else
            'OTP password did not match, please check your authenticator app'
          end
        end

        def validate_otp_part(otp)
          validate(user, otp) if otp.match(/\d*/)
        end
      end
    end
  end
end
