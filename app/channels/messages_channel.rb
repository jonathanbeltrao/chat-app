class MessagesChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find(params[:room_id] || Room.default_room.id)
    stream_from "room_#{room.id}_messages"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    room = Room.find(params[:room_id] || Room.default_room.id)
    message = Message.create!(
      content: data['message'], 
      username: data['username'],
      room: room
    )
    
    ActionCable.server.broadcast("room_#{room.id}_messages", {
      id: message.id,
      content: message.content,
      username: message.username,
      created_at: message.created_at.strftime("%I:%M %p")
    })
  end
end
