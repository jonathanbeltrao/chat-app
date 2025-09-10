class TypingChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find(params[:room_id] || Room.default_room.id)
    stream_from "room_#{room.id}_typing"
  end

  def unsubscribed
    username = params[:username]
    room = Room.find(params[:room_id] || Room.default_room.id)
    # Stop typing when user disconnects
    User.find_by(username: username)&.stop_typing!
    
    # Broadcast updated typing list
    broadcast_typing_list(room)
  end

  def start_typing(data)
    username = data['username']
    room = Room.find(params[:room_id] || Room.default_room.id)
    User.mark_user_typing(username, true)
    
    broadcast_typing_list(room)
  end

  def stop_typing(data)
    username = data['username']
    room = Room.find(params[:room_id] || Room.default_room.id)
    User.mark_user_typing(username, false)
    
    broadcast_typing_list(room)
  end

  private

  def broadcast_typing_list(room)
    typing_users = User.get_typing_users
    ActionCable.server.broadcast("room_#{room.id}_typing", {
      action: "typing_list_updated",
      typing_users: typing_users
    })
  end
end
