class TypingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "typing"
  end

  def unsubscribed
    # Remove user from typing when they disconnect
    ActionCable.server.broadcast("typing", {
      action: "stop_typing",
      username: params[:username]
    })
  end

  def start_typing(data)
    ActionCable.server.broadcast("typing", {
      action: "start_typing",
      username: data['username']
    })
  end

  def stop_typing(data)
    ActionCable.server.broadcast("typing", {
      action: "stop_typing", 
      username: data['username']
    })
  end
end
