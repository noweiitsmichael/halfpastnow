require 'pp'
class BookmarksController < ApplicationController

	def create
		@bookmark = Bookmark.new
		@bookmark.bookmarked_id = params["bookmarked_id"]
		@bookmark.bookmarked_type = params["bookmarked_type"]
		@bookmark.user_id = current_user.id
		respond_to do |format|
		  if @bookmark.save
		    format.html { redirect_to :back }
		    format.json { render json: @bookmark, status: :created, location: @bookmark }
		  else
		    format.html { redirect_to :back }
		    format.json { render json: @bookmark.errors, status: :unprocessable_entity }
		  end
		end
	end

	def new
	    @bookmark = Bookmark.new

	    respond_to do |format|
	      format.html # new.html.erb
	      format.json { render json: @bookmark }
	    end
	end

	  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

end
