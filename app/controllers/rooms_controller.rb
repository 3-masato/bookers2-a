class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    @room = Room.find(params[:id])

    is_joined_room = @room.entries.exists?(user_id: current_user.id)

    if is_joined_room
      @message = Message.new
      @messages = @room.messages

      @room.entries.each do |entry|
        unless entry.user_id == current_user.id
          @user = User.find(entry.user_id)
        end
      end
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def create
    @room = Room.create(user_id: current_user.id)

    Entry.create(room_id: @room.id, user_id: current_user.id)
    Entry.create(entry_params.merge(room_id: @room.id))

    redirect_to room_path(@room)
  end

  private

  def entry_params
    params.require(:entry).permit(:user_id, :room_id)
  end
end
