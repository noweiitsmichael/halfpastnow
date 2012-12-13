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
  	puts params

  	id = params[:bookmark][:id]
  	type = params[:bookmark][:type]

  	unless(Bookmark.where(:bookmarked_type => type, :bookmarked_id => id, :bookmark_list_id => current_user.main_bookmark_list.id).first.nil?)
  		puts "fail1"
  		respond_to do |format|
  			format.json {
  				render json: nil, status: :unprocessable_entity
  			}
  		end
  	end

  	@bookmark = current_user.main_bookmark_list.bookmarks.build
  	@bookmark.bookmarked_id = id
  	@bookmark.bookmarked_type = type

  	pp @bookmark

  	respond_to do |format|
  		format.json {
			if @bookmark.save!
	      		render json: @bookmark.id
			else 
				puts "fail2"
				render json: @bookmark.errors, status: :unprocessable_entity
			end
		}
    end
  end
end
