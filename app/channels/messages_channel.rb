class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Message.create!(
      content: data['message'], 
      username: data['username']
    )
    
    ActionCable.server.broadcast("messages", {
      id: message.id,
      content: message.content,
      username: message.username,
      created_at: message.created_at.strftime("%I:%M %p")
    })
  end
end
