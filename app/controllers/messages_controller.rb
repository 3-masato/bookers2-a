class MessagesController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :ensure_user_entry_exists, only: [:create]

  def create
    @message = current_user.messages.new(message_params)

    if @message.save
      redirect_to room_path(@message.room_id)
    else
      handle_redirect
    end
  end

  private

  def message_params
    params.require(:message).permit(:message, :room_id)
  end

  def ensure_user_entry_exists
    return if Entry.exists?(user_id: current_user.id, room_id: params[:message][:room_id])

    handle_redirect
  end

  def handle_redirect
    redirect_back(fallback_location: root_path)
  end
end