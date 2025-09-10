class MessagesController < ApplicationController
  def index
    # Username selection page
  end

  def chat
    @room = Room.default_room
    @messages = @room.messages.recent.limit(50)
    @message = Message.new
  end

  def create
    room = Room.default_room
    @message = Message.new(message_params.merge(room: room))
    
    if @message.save
      ActionCable.server.broadcast("room_#{room.id}_messages", {
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
      
      # Get the default room for broadcasting
      room = Room.default_room
      
      # Broadcast updated user list to all clients
      ActionCable.server.broadcast("room_#{room.id}_users", {
        action: "users_list_updated",
        users: User.get_online_users
      })
      
      # Broadcast updated typing list
      ActionCable.server.broadcast("room_#{room.id}_typing", {
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
