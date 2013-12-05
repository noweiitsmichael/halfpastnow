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

  def destroyBookmarkedList
    occurrence= Occurrence.find(params[:id])
    @bookmark = occurrence.all_event_bookmarks(current_user.featured_list.id).first
    
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
  	# puts params

    bookmark_list_id = params[:bookmark][:bookmark_list_id]
  	id = params[:bookmark][:id]
  	type = params[:bookmark][:type]
    comment = params[:bookmark][:comment]

  	#unless(Bookmark.where(:bookmarked_type => type, :bookmarked_id => id, :bookmark_list_id => current_user.main_bookmark_list.id).first.nil?)
    unless(Bookmark.where(:bookmarked_type => type, :bookmarked_id => id, :bookmark_list_id => bookmark_list_id).first.nil?)
  		puts "fail1"
  		respond_to do |format|
  			format.json {
  				render json: nil, status: :unprocessable_entity
  			}
  		end
  	end

    bookmark_list = current_user.bookmark_lists.find bookmark_list_id
    @bookmark = bookmark_list.bookmarks.build
    #@bookmark = current_user.main_bookmark_list.bookmarks.build

    @bookmark.bookmarked_id = id
  	@bookmark.bookmarked_type = type
    @bookmark.comment = comment

  	# pp @bookmark

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

  def create_bookmark_group
    @bookmark_list = current_user.bookmark_lists.create(name: params[:name], main_bookmarks_list: true)
    #render json: "ok"
  end

  
  def attending_create
    # puts params

    id = params[:bookmark][:id]
    type = params[:bookmark][:type]

    unless(Bookmark.where(:bookmarked_type => type, :bookmarked_id => id, :bookmark_list_id => current_user.bookmark_lists.where(:name => "Attending").first.nil?))
      puts "fail1"
      respond_to do |format|
        format.json {
          render json: nil, status: :unprocessable_entity
        }
      end
    end

    @bookmark = current_user.bookmark_lists.where(:name => "Attending").first.bookmarks.build
    @bookmark.bookmarked_id = id
    @bookmark.bookmarked_type = type

    # pp @bookmark

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
 
  def update_comment
    pp params
    id = params[:bookmark][:id]
    type = params[:bookmark][:type]
    comment = params[:bookmark][:comment]
    # @bookmark=(Bookmark.where(:bookmarked_type => "Occurrence", :bookmarked_id => type, :bookmark_list_id => current_user.featured_list.id).first.nil?) ? current_user.featured_list.bookmarks.build : Bookmark.where(:bookmarked_type => type, :bookmarked_id => id, :bookmark_list_id => current_user.featured_list.id).first
    # @bookmark=Bookmark.where(:bookmarked_type => "Occurrence",:bookmark_list_id => current_user.featured_list.id, :bookmarked_id =>id).first
    occurrence= Occurrence.find(id)
    @bookmark = occurrence.all_event_bookmarks(current_user.featured_list.id).first
    # @bookmark.comment = id
    # @bookmark.bookmarked_type = type
    @bookmark.comment = comment
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
 # Add bookmark to Top Pick List
  def add_to_featuredlist
  	id = params[:bookmark][:id]
  	type = params[:bookmark][:type]
  	comment = params[:bookmark][:comment]
  	unless(Bookmark.where(:bookmarked_type => type, :bookmarked_id => id, :bookmark_list_id => current_user.featured_list.id).first.nil?)
  		puts "fail1"
  		respond_to do |format|
  			format.json {
  				render json: nil, status: :unprocessable_entity
  			}
  		end
  	end

  	@bookmark = current_user.featured_list.bookmarks.build
  	@bookmark.bookmarked_id = id
  	@bookmark.bookmarked_type = type
  	@bookmark.comment = comment
  	
    Rails.cache.clear

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
