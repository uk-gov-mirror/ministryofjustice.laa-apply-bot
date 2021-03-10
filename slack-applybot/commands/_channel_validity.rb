module ChannelValidity
  ERROR_MESSAGE = "Sorry <@|USERNAME|>, I don't understand that command!".freeze

  class PublicError < RuntimeError
    def initialize(channel:, message: 'Channel is too public')
      SendSlackMessage.new.generic(channel: channel, as_user: true, text: message)
      super(message)
    end
  end

  private

  # def send_fail
  #   message_text = "Sorry <@#{@data.user}>, I don't understand that command!"
  #   @client.say(channel: @data.channel, text: message_text)
  # end

  def channel_is_valid?
    @channel_info = SendSlackMessage.new.conversations_info(channel: @data.channel)
    return true if @channel_info['channel']['is_im']

    channel_name = @channel_info['channel']['name']
    ENV['ALLOWED_CHANNEL_LIST'].include?(channel_name)
  end

  def channel_is_not_dm?
    @channel_info = SendSlackMessage.new.conversations_info(channel: @data.channel)
    @channel_info['channel']['is_im']&.eql?(false)
  end

  def error_message
    ERROR_MESSAGE.sub('|USERNAME|', @data.user)
  end

  def user_is_valid?
    # current user is in applyprivatebeta
  end
end
