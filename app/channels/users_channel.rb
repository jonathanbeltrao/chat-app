class UsersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "users"
    username = params[:username]
    
    # Mark user as active in database
    User.mark_user_active(username)
    
    # Broadcast updated user list to all clients
    broadcast_user_list
  end

  def unsubscribed
    username = params[:username]
    
    # Clean up user from database (they'll be removed by cleanup job)
    # Just stop their typing status immediately
    User.find_by(username: username)&.stop_typing!
    
    # Broadcast updated user list
    broadcast_user_list
  end

  def update_activity(data)
    username = data['username']
    User.mark_user_active(username)
    
    # Periodically broadcast user list to keep it fresh
    broadcast_user_list
  end

  private

  def broadcast_user_list
    active_users = User.get_active_users
    ActionCable.server.broadcast("users", {
      action: "users_list_updated",
      users: active_users
    })
  end
end
