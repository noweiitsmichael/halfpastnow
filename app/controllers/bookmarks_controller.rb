require 'pp'
class BookmarksController < ApplicationController

	def create
		@bookmark = Bookmark.new

		respond_to do |format|
		  if @bookmark.update_attributes!(params[:bookmark])
		    format.html { redirect_to :back }
		    format.json { render json: @bookmark, status: :created, location: @bookmark }
		  else
		    format.html { redirect_to :back }
		    format.json { render json: @bookmark.errors, status: :unprocessable_entity }
		  end
		  format.js
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
    
    respond_to do |format|
	    if @bookmark.destroy
	      format.html { redirect_to :back }
	      format.json { head :no_content }
	    else 
	      format.html { redirect_to :back }
		  format.json { render json: @bookmark.errors, status: :unprocessable_entity }
		end
    end
  end

  def custom_create
  	id = params[:bookmark][:id]
  	type = params[:bookmark][:type]

  	unless(Bookmark.where(:bookmarked_type => type, :bookmarked_id => id, :user_id => current_user.id).first.nil?)
  		respond_to do |format|
  			format.json { render json: nil, status: :unprocessable_entity }
  		end
  	end

  	@bookmark = current_user.bookmarks.build
  	@bookmark.bookmarked_id = id
  	@bookmark.bookmarked_type = type

  	respond_to do |format|
		if @bookmark.save
      		format.json { render json: @bookmark.id }
		else 
			format.json { render json: @bookmark.errors, status: :unprocessable_entity }
		end
    end
  end
end
