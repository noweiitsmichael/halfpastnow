require 'pp'
class ActsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index]

  layout "venues"

  def show
    @act = Act.find(params[:id])
    @occurrences  = []
    @recurrences = []
    @pictures = []
    @occs = @act.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
    @occs.each do |occ|
      # check if occurrence is instance of a recurrence
      if occ.recurrence_id.nil?
        @occurrences << occ
      else
        if @recurrences.index(occ.recurrence).nil?
          @recurrences << occ.recurrence
        end
      end
    end

    @act.pictures.each do |pic|
      @pictures << pic
    end

    respond_to do |format|
      format.html { render :layout => "mode" }
      format.json { render json: { :occurrences => @occurrences.to_json(:include => :event), :recurrences => @recurrences.to_json(:include => :event), 
                                   :act => @act.to_json, :pictures => @pictures.to_json } } 
    end
  end

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @acts = Act.includes(:events, :tags, :embeds).all.sort_by{ |act| act.name }

    render :layout => "admin"
  end


  def destroy
    @act = Act.find(params[:id])
    @act.destroy

    render json: {:act_id => @act.id }
  end

  def actCreate
    #pp params
    authorize! :actCreate, @user, :message => 'Not authorized as an administrator.'  
    if (params[:act][:id].to_s.empty?)
      @act = Act.new()
    else
      @act = Act.find(params[:act][:id])
    end
    #puts params[:act]
    @act.update_attributes!(params[:act])

    unless params[:pictures].nil? 
      params[:pictures].each do |pic|
          #puts pic
          #puts pic[1]["id"]
          addedPic = Picture.find(pic[1]["id"])
          addedPic.pictureable_id = @act.id
          addedPic.save!
      end
    end


    respond_to do |format|
      if @act.save
        format.html { redirect_to :action => :index, :notice => 'yay' }
        format.json { render json: { :name => @act.name, :text => @act.name, :id => @act.id, :tags => (@act.tags.collect { |t| t.id.to_s } * ","), :completedness => @act.completedness } }
      else
        format.html { redirect_to :action => :index, :notice => 'boo' }
        format.json { render json: false }
      end
    end
  end

  def actFind
    if(params[:contains])
      # @acts = Act.where("name ilike ?", "%#{params[:contains]}%").collect {|a| { :name => "#{a.name}", :text => "#{a.name}", :id => a.id, :fb_picture => a.fb_picture, :tags => (a.tags.collect { |t| t.id.to_s } * ",") , :pictures => a.pictures } }
      @acts = Act.where("name ilike ?", "%#{params[:contains]}%").collect {|a| { :name => "#{a.name}", :text => "#{a.name}", :id => a.id, :fb_picture => a.fb_picture, :tags => (a.tags.collect { |t| t.id.to_s } * ",") , :pictures => a.pictures } }
    else
      @acts = []
    end

    render json: @acts
  end

  def actsMode
    if(params[:id].to_s.empty?)
      @act = Act.new
    else
      @act = Act.find(params[:id])
    end
    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})

    render :layout => false
  end

end
