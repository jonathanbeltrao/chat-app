class UserCleanupJob < ApplicationJob
  queue_as :default

  def perform
    # Clean up inactive users and broadcast updated lists
    User.cleanup_inactive_users
    
    # Broadcast updated user list to all connected clients
    ActionCable.server.broadcast("users", {
      action: "users_list_updated",
      users: User.get_active_users
    })
    
    # Broadcast updated typing list
    ActionCable.server.broadcast("typing", {
      action: "typing_list_updated", 
      typing_users: User.get_typing_users
    })
    
    # Schedule next cleanup in 30 seconds
    UserCleanupJob.set(wait: 30.seconds).perform_later
  end
end
