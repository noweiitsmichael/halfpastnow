require 'pp'
require 'ruby-prof'

class VenuesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :authenticate_user!, :only => [:show, :find]
  
  # GET /venues
  # GET /venues.json
  def index


    # authorize! :index, @user, :message => 'Not authorized as an administrator.'
    
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
      SELECT venue_id,venues.name,COUNT(*) 
        FROM venues,events
        WHERE venues.id = events.venue_id
        GROUP BY venue_id,venues.name
        ORDER BY COUNT(*) DESC")
  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    @venue = Venue.find(params[:id])
    puts "venue_id "
    puts  params[:id]
    @venue.clicks += 1
    @venue.save
    @jsonOccs  = []
    @jsonRecs = []
    @occurrences = @venue.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
    @occurrences.each do |occ|
      # check if occurrence is instance of a recurrence
      if occ.recurrence_id.nil?
        @jsonOccs << occ
      else
        if @jsonRecs.index(occ.recurrence).nil?
          @jsonRecs << occ.recurrence
        end
      end
    end
    puts "jsonrecs:"
    pp @jsonRecs

    respond_to do |format|
      format.json { render json: { :occurrences => @jsonOccs.to_json(:include => :event), :recurrences => @jsonRecs.to_json(:include => :event), :venue => @venue.to_json } } 
      format.mobile { render json: { :occurrences => @jsonOccs.to_json(:include => :event), :recurrences => @jsonRecs.to_json(:include => :event), :venue => @venue.to_json } } 
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
        puts "here save"
        format.html { redirect_to action: :index }
        format.json { render json: @venue, status: :created, location: @venue }
      else
        puts "here not save"
        format.html { render action: "new" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update

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
    # result = RubyProf.profile do

    @venue = Venue.find(params[:id])

    @event = @venue.events.build()
    @event.update_attributes(params[:event])
    @event.user_id = current_user.id



    if @event.save
      @raw_event = RawEvent.find(params[:raw_event_id])
      @raw_event.submitted = true
      if @raw_event.save
        render json: true
      else
        render json: false
      end
    else
      render json: false
    end


    # end

    # File.open "/home/rumblerob/workspace/rails_projects/halfpastnow/tmp/profile-graph.html", 'w' do |file|
    #   RubyProf::GraphHtmlPrinter.new(result).print(file)
    # end
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to venues_url }
      format.json { head :ok }
    end
  end
end
