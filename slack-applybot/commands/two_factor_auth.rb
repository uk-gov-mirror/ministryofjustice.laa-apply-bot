module SlackApplybot
  module Commands
    class TwoFactorAuth < SlackRubyBot::Commands::Base
      require 'rotp'
      require 'rqrcode'

      command '2fa' do |client, data, match|
        @client = client
        @data = data
        @user = user
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        client.typing(channel: data.channel)
        case match['expression']&.downcase
        when 'setup'
          user_dm = user_dm_channel(client)
          if user_has_github_linked?
            send_qr_message(user_dm)
          else
            send_dm_to_link_github(user_dm)
          end
          message = "I've sent you a DM, we probably shouldn't be talking about this in public!" if channel_is_not_dm?
        when /^confirm/
          client.say(channel: user_dm_channel(client), text: process_confirmation(match))
          message = "I've sent you a DM, we probably shouldn't be talking about this in public!" if channel_is_not_dm?
        else
          message = "You called `2fa` with `#{match['expression']}`. This is not supported."
        end
        client.say(channel: data.channel, text: message) if message
      end

      class << self
        include ChannelValidity
        include TwoFactorAuthShared
        include UserCommand

        def process_confirmation(match)
          parts = match['expression'].split - ['confirm']
          if parts.empty?
            'OTP password not provided, please call as `2fa confirm 000000`'
          elsif validate_otp_part(parts[0])
            'OTP has been successfully configured'
          else
            'OTP password did not match, please check your authenticator app'
          end
        end

        def send_dm_to_link_github(channel)
          message = 'You need to link your github account before you can setup 2FA'
          @client.say(channel: channel, text: message)
        end

        def send_qr_message(channel)
          user.otp_secret = ROTP::Base32.random if user.encrypted_2fa_secret.nil?
          token = Encryption::Service.decrypt(user.encrypted_2fa_secret)
          SendSlackMessage.new.upload_file(
            channels: channel,
            as_user: true,
            file: Faraday::FilePart.new(StringIO.new(build_qr_code(token)), 'image/png'),
            title: 'Your apply-bot QR',
            initial_comment: 'Scan with an authenticator app'
          )
        end

        def build_qr_code(token)
          totp = ROTP::TOTP.new(token, issuer: ENV.fetch('SERVICE_NAME'))
          qrcode = RQRCode::QRCode.new(totp.provisioning_uri(ENV.fetch('SERVICE_EMAIL')))

          qrcode.as_svg(
            size: 1,
            offset: 10,
            shape_rendering: 'crispEdges',
            module_size: 6,
            standalone: true
          )
        end
      end
    end
  end
end
