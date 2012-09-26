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
    @bookmark.destroy
    respond_to do |format|
	    if
	      format.html { redirect_to :back }
	      format.json { head :no_content }
	    else 
	      format.html { redirect_to :back }
		  format.json { render json: @bookmark.errors, status: :unprocessable_entity }
		end
    end
  end

end
