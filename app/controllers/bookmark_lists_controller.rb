require 'pp'
class BookmarkListsController < ApplicationController

	layout "admin"

  def index
  	authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @bookmarklists = BookmarkList.where(:featured => true)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bookmarklists }
    end
  end

  # GET /bookmarkLists/1
  # GET /bookmarkLists/1.json
  def show
    @bookmarklist = BookmarkList.find(params[:id])

    #ads
    @advertisement = Advertisement.where(:placement => 'sidebar').where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first
    @advertisement.update_attributes(views: (@advertisement.views.to_i + 1)) unless @advertisement.nil?

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bookmarklist }
    end
  end

  # GET /bookmarkLists/new
  # GET /bookmarkLists/new.json
  def new
    @bookmarklist = BookmarkList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bookmarklist }
    end
  end

  # GET /bookmarkLists/1/edit
  def edit
  	pp "Edit"
    @bookmarklist = BookmarkList.find(params[:id])

    pp @bookmarklist
  end

  # POST /bookmarkLists
  # POST /bookmarkLists.json
  def create
  	pp "Create"
  	pp params
    
    @bookmarklist = BookmarkList.new(params[:bookmark_list])

    pp @bookmarklist


      if @bookmarklist.save
      	if params[:bookmark_list][:picture].present? || params[:bookmark_list][:remote_picture_url].present? 
      		render action: "crop"
      	else
        	redirect_to bookmark_lists_url, notice: 'BookmarkList was successfully created.'
        end
      else
        render action: "new"
      end

  end

  # PUT /bookmarkLists/1
  # PUT /bookmarkLists/1.json
  def update
  	pp "Update"
  	pp params
    @bookmarklist = BookmarkList.find(params[:id])

      if @bookmarklist.update_attributes(params[:bookmark_list])
        if params[:bookmark_list][:picture].present? || params[:bookmark_list][:remote_picture_url].present? 
        	@bookmarklist.picture_url = @bookmarklist.picture_url(:thumb)
        	@bookmarklist.save
      		render action: "crop"
      	else
        	redirect_to bookmark_lists_url, notice: 'BookmarkList was successfully updated.'
        end

      else
        render action: "new"
      end
  end

  # DELETE /bookmarkLists/1
  # DELETE /bookmarkLists/1.json
  def destroy
    @bookmarklist = BookmarkList.find(params[:id])
    @bookmarklist.destroy

    respond_to do |format|
      format.html { redirect_to bookmark_lists_url }
      format.json { head :no_content }
    end
  end

end
