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
      SELECT venues.id, venues.name, venues.address, venues.views, COUNT(events.id) AS events_count
        FROM venues
        LEFT OUTER JOIN events
        ON venues.id = events.venue_id
        GROUP BY venues.id,venues.name
        ORDER BY events_count DESC")
    
    # would be nice but "venue_id" is the label in @venuesCooked and "id" is the label in @venuesRaw
    # instead we'll have to iterate through @venuesRaw in the table
    # @venuesCombined = (@venuesRaw+@venuesCooked).group_by{|h| h["venue_id"]}.map{|k,v| v.reduce(:merge)}
  

    # Will have to come back and make dataTables serverside, see http://railscasts.com/episodes/340-datatables?view=asciicast
  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    @venue = Venue.find(params[:id])

    @venue.clicks += 1
    @venue.save
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

      format.html { render :layout => "mode" }
      format.json { render json: { :occurrences => @occurrences.to_json(:include => :event), :recurrences => @recurrences.to_json(:include => :event), :venue => @venue.to_json } } 
      format.mobile { render json: { :occurrences => @occurrences.to_json(:include => :event), :recurrences => @recurrences.to_json(:include => :event), :venue => @venue.to_json } } 

    end
  end

  # GET /venues/find
  def find
    if(params[:contains])
      @venues = Venue.where("name ilike ?", "%#{params[:contains]}%").collect {|v| { :label => "#{v.name} (#{v.address})", :value => "#{v.name} (#{v.address})", :id => v.id } }
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
      format.html # new.html.erb
      format.json { render json: @venue }
    end
  end

  # GET /venues/edit/1
  def edit
    authorize! :edit, @user, :message => 'Not authorized as an administrator.'
    @venue = Venue.includes(:tags, :events => :tags, :raw_venues => :raw_events).find(params[:id])

    @venue.events.build
    @venue.events.each do |event| 
      event.occurrences.build
      event.recurrences.build
    end

    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})

  end

  # POST /venues
  # POST /venues.json
  def create
    @venue = Venue.new(params[:venue])

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
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @venue = Venue.find(params[:id])

    if(params[:venue][:events_attributes])
      params[:venue][:events_attributes].each do |params_event|
        if params_event[1]["id"].nil?
          params_event[1]["user_id"] = current_user.id
        end
      end
    end

    respond_to do |format|
      if @venue.update_attributes!(params[:venue])
        format.html { redirect_to :action => :edit, :id => @venue.id, :notice => 'yay' }
        format.json { head :ok }
      else
        format.html { redirect_to :action => :edit, :id => @venue.id, :notice => 'boo' }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /venues/new
  # GET /venues/new.json
  def fromRaw
    @venue = Venue.find(params[:id])
    pp @venue
    @event = @venue.events.build()
    @event.update_attributes(params[:event])
    @event.user_id = current_user.id
    
    if @event.save
      @raw_event = RawEvent.find(params[:raw_event_id])
      @raw_event.submitted = true
      @raw_event.save
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

  def deleteAct
    @act = Act.find(params[:id])
    @act.destroy

    render json: {:act_id => @act.id }
  end

  def rawEvent
    @rawEvent = RawEvent.find(params[:id])

    @venue = @rawEvent.raw_venue.venue

    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})
    
    render :layout => false
  end 

  def event

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

  def eventEdit
    @venue = Venue.find(params[:venue_id])
    if(params[:id].to_s.empty?)
      @event = @venue.events.build
    else
      @event = Event.find(params[:id])
      params[:event]["user_id"] = current_user.id
    end

    respond_to do |format|
      if @event.update_attributes!(params[:event])
        format.html { redirect_to :action => :edit, :id => @venue.id, :notice => 'yay' }
        format.json { render json: { :from => "eventEdit", :result => true } }
      else
        format.html { redirect_to :action => :edit, :id => @venue.id, :notice => 'boo' }
        format.json { render json: { :from => "eventEdit", :result => false } }
      end
    end
  end

  # GET /venues/find
  def actFind
    if(params[:contains])
      @acts = Act.where("name ilike ?", "%#{params[:contains]}%").collect {|a| { :name => "#{a.name}", :text => "#{a.name}", :id => a.id, :tags => (a.tags.collect { |t| t.id.to_s } * ",") } }
    else
      @acts = []
    end

    render json: @acts
  end

  def actCreate
    authorize! :actCreate, @user, :message => 'Not authorized as an administrator.'    
    if (params[:act][:id].to_s.empty?)
      @act = Act.new()
    else
      @act = Act.find(params[:act][:id])
    end
    puts params[:act]
    @act.update_attributes!(params[:act])

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

private

  def only_allow_admin
    redirect_to root_path, :alert => 'Not authorized as an administrator.' unless current_user.has_role? :admin
  end
