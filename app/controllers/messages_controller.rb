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

  private

  def message_params
    params.require(:message).permit(:content, :username)
  end
end
