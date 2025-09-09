class UsersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "users"
    username = params[:username]
    
    # Mark user as online in database
    User.mark_user_online(username)
    
    # Broadcast updated user list to all clients
    broadcast_user_list
  end

  def unsubscribed
    username = params[:username]
    
    # Mark user as offline in database
    User.mark_user_offline(username)
    
    # Broadcast updated user list
    broadcast_user_list
  end

  def update_activity(data)
    username = data['username']
    # Just ensure user is still marked as online
    User.mark_user_online(username)
    
    # No need to broadcast every activity update since online status is binary
  end

  private

  def broadcast_user_list
    online_users = User.get_online_users
    ActionCable.server.broadcast("users", {
      action: "users_list_updated",
      users: online_users
    })
  end
end
