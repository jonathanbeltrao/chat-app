class MessagesChannel < ApplicationCable::Channel
  def subscribed
    room = Room.default_room
    stream_from "messages_room_#{room.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    room = Room.default_room
    message = Message.create!(
      content: data['message'], 
      username: data['username'],
      room: room
    )
    
    ActionCable.server.broadcast("messages_room_#{room.id}", {
      id: message.id,
      content: message.content,
      username: message.username,
      created_at: message.created_at.strftime("%I:%M %p")
    })
  end
end
