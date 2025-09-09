class TypingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "typing"
  end

  def unsubscribed
    username = params[:username]
    # Stop typing when user disconnects
    User.find_by(username: username)&.stop_typing!
    
    # Broadcast updated typing list
    broadcast_typing_list
  end

  def start_typing(data)
    username = data['username']
    User.mark_user_typing(username, true)
    
    broadcast_typing_list
  end

  def stop_typing(data)
    username = data['username']
    User.mark_user_typing(username, false)
    
    broadcast_typing_list
  end

  private

  def broadcast_typing_list
    typing_users = User.get_typing_users
    ActionCable.server.broadcast("typing", {
      action: "typing_list_updated",
      typing_users: typing_users
    })
  end
end
