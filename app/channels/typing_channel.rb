class TypingChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find(params[:room_id] || Room.default_room.id)
    stream_from "room_#{room.id}_typing"
  end

  def unsubscribed
    username = params[:username]
    room = Room.find(params[:room_id] || Room.default_room.id)
    
    ActionCable.server.broadcast("room_#{room.id}_typing", {
      action: "user_stopped_typing",
      username: username
    })
  end

  def start_typing(data)
    username = data['username']
    room = Room.find(params[:room_id] || Room.default_room.id)
    
    ActionCable.server.broadcast("room_#{room.id}_typing", {
      action: "user_started_typing",
      username: username
    })
  end

  def stop_typing(data)
    username = data['username']
    room = Room.find(params[:room_id] || Room.default_room.id)
    
    ActionCable.server.broadcast("room_#{room.id}_typing", {
      action: "user_stopped_typing",
      username: username
    })
  end
end
