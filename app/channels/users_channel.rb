class UsersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "users"
    # Add user to online list
    ActionCable.server.broadcast("users", {
      action: "user_joined",
      username: params[:username]
    })
  end

  def unsubscribed
    # Remove user from online list
    ActionCable.server.broadcast("users", {
      action: "user_left", 
      username: params[:username]
    })
  end

  def update_activity(data)
    ActionCable.server.broadcast("users", {
      action: "user_activity",
      username: data['username']
    })
  end
end
