class MessagesController < ApplicationController
  def index
    # Username selection page
  end

  def chat
    @messages = Message.recent.limit(50)
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    
    if @message.save
      ActionCable.server.broadcast("messages", {
        id: @message.id,
        content: @message.content,
        username: @message.username,
        created_at: @message.created_at.strftime("%I:%M %p")
      })
      head :ok
    else
      render json: { errors: @message.errors }, status: :unprocessable_entity
    end
  end

  def logout
    username = params[:username]
    
    if username.present?
      # Mark user as offline in database
      User.mark_user_offline(username)
      
      # Broadcast updated user list to all clients
      ActionCable.server.broadcast("users", {
        action: "users_list_updated",
        users: User.get_online_users
      })
      
      # Broadcast updated typing list
      ActionCable.server.broadcast("typing", {
        action: "typing_list_updated", 
        typing_users: User.get_typing_users
      })
      
      head :ok
    else
      render json: { error: "Username required" }, status: :bad_request
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :username)
  end
end
