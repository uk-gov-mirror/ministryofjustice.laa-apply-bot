module UserCommand
  def user
    User.find_or_create_by(slack_id: @data.user)
  end

  def user_dm_channel(client)
    client.web_client.conversations_open(users: user)['channel']['id']
  end
end
