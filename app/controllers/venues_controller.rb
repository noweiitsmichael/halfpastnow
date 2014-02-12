require 'pp'
require 'ruby-prof'

class VenuesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :update, :edit, :actCreate]
  # skip_before_filter :authenticate_user!, :only => [:show, :find]
  #before_filter :only_allow_admin, :only => [ :index ]
  # GET /venues
  # GET /venues.json
  def index

     authorize! :index, @user, :message => 'Not authorized as an administrator.'
    
    # @venues = Venue.all
    # @venues = RawEvent.where(:submitted => nil, :deleted => nil).collect { |raw_event| raw_event.raw_venue ? raw_event.raw_venue.venue : nil }.compact
    # @num_raw_events = Hash.new(0)
    # @venues.each { |venue| @num_raw_events[venue.id] += 1 }
    # @venues.uniq!

    @venuesRaw = ActiveRecord::Base.connection.select_all("
      SELECT venue_id,venues.name,COUNT(*) 
        FROM venues,raw_venues,raw_events 
        WHERE venues.id = raw_venues.venue_id AND raw_venues.id = raw_events.raw_venue_id AND raw_events.submitted IS NULL AND raw_events.deleted IS NULL
        GROUP BY venue_id,venues.name
        ORDER BY COUNT(*) DESC")

    @venuesCooked = ActiveRecord::Base.connection.select_all("
      SELECT venues.id , venues.name, venues.address, venues.views, COUNT(events.id) AS events_count
        FROM venues
        LEFT OUTER JOIN events
        ON venues.id = events.venue_id
        GROUP BY venues.id,venues.name
        ORDER BY events_count DESC")
    
    # would be nice but "venue_id" is the label in @venuesCooked and "id" is the label in @venuesRaw
    # instead we'll have to iterate through @venuesRaw in the table
    ## (not deleting because its awesome code)
    # @venuesCombined = (@venuesRaw+@venuesCooked).group_by{|h| h["venue_id"]}.map{|k,v| v.reduce(:merge)}
  
    @venuesCooked.each do |venue|
      intersect_venue = @venuesRaw.find{|id| id["venue_id"] == venue["id"]}
      if intersect_venue.nil? == false
        venue.merge!({ "raw_events_count" => intersect_venue["count"]})
      else
        venue.merge!({ "raw_events_count" => 0})
      end
    end
    
    respond_to do |format|
      format.html {render :layout => "admin"}
      format.json { render json: VenuesDatatable.new(view_context) }
    end

  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    params[:fullmode]=true
    @fullmode = !params[:fullmode].to_s.empty?
    if(@mobileMode)
        unless params[:format].to_s.eql? "mobile"
          redirect_to :action => "android"  
        else
          return
        end
        
    end
    @modeType = "venue"

    #ads
    @advertisement = Advertisement.where(:placement => 'details').where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first
    @advertisement.update_attributes(views: (@advertisement.views.to_i + 1)) unless @advertisement.nil?

    @venue = Venue.find(params[:id])
    @pageTitle = @venue.name + " | half past now."

    @venue.clicks += 1
    @venue.save
    if(current_user)
      @bookmarks = Bookmark.where(:bookmarked_type => 'Venue', :bookmarked_id => @venue.id, :bookmark_list_id => current_user.bookmark_lists.collect(&:id))
      @bookmark_lists_ids = @bookmarks.empty? ? [0] : @bookmarks.collect(&:bookmark_list_id)
      #@bookmarkId = bookmark.nil? ? nil : bookmark.id
    else
      @bookmarkId = nil
    end
    
    @occurrences  = []
    @recurrences = []
    @occs = @venue.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
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

    respond_to do |format|
      if @fullmode
        format.html { render :layout => "fullmode" }
      else
        format.html { render :layout => "mode" }
      end
      format.json { render json: { :occurrences => @occurrences.to_json(:include => :event), :recurrences => @recurrences.to_json(:include => :event), :venue => @venue.to_json } } 
      format.mobile 
    end
  end

  # GET /venues/find
  def find
    if(params[:contains])
      searchterm = params[:contains].gsub(/[^0-9a-z ]/i, '').upcase
      @venues = Venue.where("regexp_replace(name, '[^0-9a-zA-Z ]', '') ilike '%#{searchterm}%'").collect {|v| { :label => "#{v.name} (#{v.address})", :value => "#{v.name} (#{v.address})", :id => v.id } }
    else
      @venues = []
    end

    render json: @venues
  end

  # GET /venues/new
  # GET /venues/new.json
  def new
    @venue = Venue.new

    respond_to do |format|
      format.html { render :layout => "admin" }
      format.json { render json: @venue }
    end
  end

  # GET /venues/edit/1
  def edit
    @venue = Venue.find(params[:id])

    render :layout => "admin"
  end

  def list_events
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @venue = Venue.includes(:tags, :events => :tags).find(params[:id])

    # Is this even needed at all?
    # @venue.events.build
    # @venue.events.each do |event| 
    #   event.occurrences.build
    #   event.recurrences.build
    # end

    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})

    render :layout => "admin"
  end

  def list_raw_events
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @venue = Venue.includes(:raw_venues => :raw_events).find(params[:id])
    puts @venue

    render :layout => "admin"
  end

  def list_deleted_events
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @venue = Venue.includes(:raw_venues => :raw_events).find(params[:id])
    puts @venue

    render :layout => "admin"
  end

  def new_event
    puts "new_event:"
    # puts params
    @venue = Venue.find(params[:id])
    @event = @venue.events.build

    @event.occurrences.build
    @event.recurrences.build
    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})

    render :layout => "admin"
  end

  # POST /venues
  # POST /venues.json
  def create
    puts "....creating venue..."
    @venue = Venue.new(params[:venue])
    @venue.updated_by = current_user.id
    @venue.completion = @venue.completedness

    respond_to do |format|
      if @venue.save
        format.html { redirect_to action: :index }
        format.json { render json: @venue, status: :created, location: @venue }
      else
        format.html { render action: "new" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    puts "update venues"
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @venue = Venue.find(params[:id])

    if(params[:venue][:events_attributes])
      params[:venue][:events_attributes].each do |params_event|
        if params_event[1]["id"].nil?
          params_event[1]["user_id"] = current_user.id
        end
      end
    end

    @venue.completion = @venue.completedness
    @venue.updated_by = current_user.id

    respond_to do |format|
      if @venue.update_attributes!(params[:venue])
        format.html { redirect_to :action => :edit, :id => @venue.id}
        format.json { head :ok }
      else
        format.html { redirect_to :action => :edit, :id => @venue.id}
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /venues/new
  # GET /venues/new.json
  def fromRaw
    @venue = Venue.find(params[:id])
    puts "creating from raw......."
    # pp params
    @event = @venue.events.build()
    @event.user_id = current_user.id
    @event.update_attributes!(params[:event])
    unless params[:bookmark_lists_add].blank?
      Bookmark.create(:bookmarked_type => "Occurrence", :bookmarked_id => @event.nextOccurrence.id, :bookmark_list_id => params[:bookmark_lists_add] )
      @event.clicks += 100
    end

    EventfulData.where(:element_type => "RawEvent", :element_id => params[:raw_event_id]).each do |i|
      if i.data_type == "recurrence" || i.data_type == "instance"
        i.element_type = "Event"
        i.element_id = @event.id
        i.save!
      end
    end
    
    newpictures = Picture.where(:pictureable_type => "RawEvent", :pictureable_id => params[:raw_event_id]) 
    unless newpictures.nil?
      newpictures.each do |pic|
        updatePic = Picture.find(pic.id)
        updatePic.pictureable_id = @event.id
        updatePic.pictureable_type = "Event"
        updatePic.save!
      end
    end

    @raw_event = RawEvent.find(params[:raw_event_id])
    @event.cover_image = @raw_event.cover_image
    @event.cover_image_url = @raw_event.cover_image_url
    
    if @event.save
      @raw_event.submitted = true
      @raw_event.save
      @event.completion = @event.completedness
      @event.save
      render json: {:event_id => @event.occurrences.first.id, :event_title => @event.title}
    else
      render json: {:event_id => nil}
    end
  end

  def editRawVenue
    @venue = Venue.includes(:raw_venues).find(params[:id])

    events_url = ""
    if(!params[:rawVenueString].to_s.empty?)
      events_url = "http://do512.com/venue/#{params[:rawVenueString]}?format=xml"
    elsif(!params[:rawVenueFullString].to_s.empty?)
      events_url = params[:rawVenueFullString]
    else
      redirect_to :action => :edit, :id => @venue.id, :notice => 'boo'
    end

    raw_venue = @venue.raw_venues.find { |rv| rv.from == "do512" }
    if(!raw_venue)
      raw_venue = @venue.raw_venues.build(:from => "do512", :events_url => events_url)
    else 
      raw_venue.events_url = events_url
    end

    if raw_venue.save
      redirect_to :action => :edit, :id => @venue.id, :notice => 'yay'
    else
      redirect_to :action => :edit, :id => @venue.id, :notice => 'boo'
    end
  end

  def delete
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to venues_url }
      format.json { head :ok }
    end
  end

  def deleteRawEvent
    @raw_event = RawEvent.find(params[:id])
    @raw_event.deleted = true
    @raw_event.save

    render json: {:event_id => @raw_event.id }
  end

  def deleteEvent
    @event = Event.find(params[:id])
    @event.destroy

    render json: {:event_id => @event.id }
  end

  def rawEvent
    @rawEvent = RawEvent.find(params[:id])

    @venue = @rawEvent.raw_venue.venue

    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})
    
    render :layout => false
  end 

  def event
    puts "event"

    if(params[:id].to_s.empty?)
      @venue = Venue.find(params[:venue_id])
      @event = @venue.events.build
    else
      @event = Event.find(params[:id])
      @venue = @event.venue
    end

    @event.occurrences.build
    @event.recurrences.build

    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})
    
    render :layout => false
  end 

  def setOwner
    @venue = Venue.find(params[:venue_id])
    @venue.assigned_admin = params[:user_id]
    @venue.save!

    render json: {:venue_id => @venue.id}
  end

  def removeOwner
    @venue = Venue.find(params[:venue_id])
    @venue.assigned_admin = nil
    @venue.save!

    render json: {:venue_id => @venue.id}
  end

  def eventEdit
    #puts "eventEdit"
    #pp params
    @venue = Venue.find(params[:venue_id])
    if(params[:id].to_s.empty?)
      @event = @venue.events.build
      params[:event][:id] = @event.id
    else
      @event = Event.find(params[:id])
    end

    params[:event][:user_id] = current_user.id
    if params[:event][:cover_image]
      @event.cover_image_url = Picture.find(params[:event][:cover_image]).image_url(:cover)
    end

    @event.update_attributes!(params[:event])

    unless params[:bookmark_lists_add].blank?
      Bookmark.create(:bookmarked_type => "Occurrence", :bookmarked_id => @event.nextOccurrence.id, :bookmark_list_id => params[:bookmark_lists_add] )
      @event.clicks += 100
    end

    unless params[:event][:pictures_attributes].nil?
      params[:event][:pictures_attributes].each do |pic|
        if pic[1][:_destroy].nil?
          updatePic = Picture.find(pic[1][:id])
          updatePic.pictureable_id = @event.id
          updatePic.save!
        end
      end
    end

    respond_to do |format|
      if @event.save!
        @event.completion = @event.completedness
        @event.save
        @event.occurrences.each do |occ|
          occ.slug = "#{occ.event.title.truncate(40)}-at-#{occ.event.venue.name.truncate(40)}" rescue "#{occ.id}"
          occ.save
        end
        format.html { redirect_to :action => :list_events, :id => @venue.id }
        format.json { render json: { :from => "eventEdit", :result => true } }
      else
        format.html { redirect_to :action => :edit, :id => @venue.id, :notice => 'boo' }
        format.json { render json: { :from => "eventEdit", :result => false } }
      end
    end
  end
end
  # GET /venues/find


private

  def only_allow_admin
    redirect_to root_path, :alert => 'Not authorized as an administrator.' unless current_user.has_role? :admin
  end
