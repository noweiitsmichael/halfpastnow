class BookmarksController < ApplicationController

	def create
		@bookmark = Bookmark.new(params[:bookmark])
		
		puts "Bookmark Info:"
		puts params[:bookmark]
		puts "Bookmark Object:"
		puts @bookmark
		respond_to do |format|
		  if @bookmark.save
		    format.html { redirect_to :back }
		    format.json { render json: @bookmark, status: :created, location: @bookmark }
		  else
		    format.html { render action: "new" }
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

end
