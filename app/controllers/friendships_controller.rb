class FriendshipsController < ApplicationController

	def create
	  @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
	  if @friendship.save
	    flash[:notice] = "Added friend."
	    redirect_to "friendships"
	  else
	    flash[:notice] = "Unable to add friend."
	    redirect_to "friendships"
	  end
	end

	def destroy
		@friendship = Friendship.find(params[:id])
		@friendship.destroy

		respond_do do |format|
			format.js
		end
	end
	

end
