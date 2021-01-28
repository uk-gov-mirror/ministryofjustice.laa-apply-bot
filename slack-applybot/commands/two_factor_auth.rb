module SlackApplybot
  module Commands
    class TwoFactorAuth < SlackRubyBot::Commands::Base
      require 'rotp'
      require 'rqrcode'

      command '2fa setup' do |client, data, _match|
        @client = client
        @data = data
        raise ChannelValidity::PublicError.new(message: error_message, channel: @data.channel) unless channel_is_valid?

        client.typing(channel: data.channel)
        channel = data.channel
        if channel_is_not_dm?
          message_text = "I've sent you a DM, we probably shouldn't be talking about this in public!"
          client.say(channel: channel, text: message_text)
          channel = client.web_client.conversations_open(users: data['user'])['channel']['id']
        end

        send_qr_message(channel)
      end

      class << self
        include ChannelValidity
        include UserCommand

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
