require 'pp'
require 'open-uri'
require 'json'

# brittle as hell, because these have to change if we change the map size, and also if we change locales from Austin.
class ZoomDelta
  HighLatitude = 0.037808182 / 2
  HighLongitude = 0.02617836 / 2
  MediumLatitude = 0.0756264644 / 2
  MediumLongitude = 0.05235672 / 2
  LowLatitude = 0.30250564 / 2
  LowLongitude = 0.20942688 / 2
end

class EventsController < ApplicationController

def index

    unless(params[:channel_id])
    end
    
    @tags = Tag.all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }

    pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"

    # search
    unless(params[:search].to_s.empty?)
      search = params[:search].gsub(/[^0-9a-z ]/i, '').upcase
      searches = search.split(' ')
      
      search_match_arr = []
      searches.each do |word|
        search_match_arr.push("(upper(venues.name) LIKE '%#{word}%' OR upper(events.description) LIKE '%#{word}%' OR upper(events.title) LIKE '%#{word}%')")
      end

      search_match = search_match_arr * " AND "
    end


    # date/time
    start_date_check = "occurrences.start >= '#{Date.today()}'"
    end_date_check = start_time_check = end_time_check = day_check = "TRUE"
    occurrence_start_time = "((EXTRACT(HOUR FROM occurrences.start) * 3600) + (EXTRACT(MINUTE FROM occurrences.start) * 60))"

    unless(params[:start_days].to_s.empty? && params[:end_days].to_s.empty?)
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 365000 : params[:end_days].to_i + 1))

      start_date_check = "occurrences.start >= '#{event_start_date}'"
      end_date_check = "occurrences.start <= '#{event_end_date}'"
    end

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','

      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{day_check}"


    # location
    if(params[:lat_min].to_s.empty? || params[:long_min].to_s.empty? || params[:lat_max].to_s.empty? || params[:long_max].to_s.empty?)
      @ZoomDelta = {
               11 => { :lat => 0.30250564 / 2, :long => 0.20942688 / 2 }, 
               13 => { :lat => 0.0756264644 / 2, :long => 0.05235672 / 2 }, 
               14 => { :lat => 0.037808182 / 2, :long => 0.02617836 / 2 }
              }

      # 30.268093,-97.742808
      @lat = 30.268093
      @long = -97.742808
      @zoom = 11

      unless params[:location].to_s.empty?
        json_object = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + URI::encode(params[:location])).read)
        unless (json_object.nil? || json_object["results"].length == 0)

          @lat = json_object["results"][0]["geometry"]["location"]["lat"]
          @long = json_object["results"][0]["geometry"]["location"]["lng"]
          # if the results are of a city, keep it zoomed out aways
          if (json_object["results"][0]["address_components"][0]["types"].index("locality").nil?)
            @zoom = 14
          end
        end
      end

      @lat_delta = @ZoomDelta[@zoom][:lat]
      @long_delta = @ZoomDelta[@zoom][:long]
      @lat_min = @lat - @lat_delta
      @lat_max = @lat + @lat_delta
      @long_min = @long - @long_delta
      @long_max = @long + @long_delta
    else
      @lat_min = params[:lat_min]
      @lat_max = params[:lat_max]
      @long_min = params[:long_min]
      @long_max = params[:long_max]
    end

    location_match = "venues.id = events.venue_id AND venues.latitude >= #{@lat_min} AND venues.latitude <= #{@lat_max} AND venues.longitude >= #{@long_min} AND venues.longitude <= #{@long_max}"

    # tags
    unless(params[:included_tags].to_s.empty?)
      tags_mush = params[:included_tags] * ','

      tag_include_match = "events.id IN (
                    SELECT event_id 
                      FROM events, tags, events_tags 
                      WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
                      GROUP BY event_id 
                      HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
                  )"
    end

    unless(params[:excluded_tags].to_s.empty?)
      tags_mush = params[:excluded_tags] * ','
      tag_exclude_match = "events.id NOT IN (
                    SELECT event_id 
                      FROM events, tags, events_tags 
                      WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
                      GROUP BY event_id
                  )"
    end

    # price
    unless(params[:low_price].to_s.empty?)
      low_price = params[:low_price].to_i
      low_price_match = "events.price >= #{low_price}"
    end

    unless(params[:high_price].to_s.empty?)
      high_price = params[:high_price].to_i
      high_price_match = "events.price <= #{high_price}"
    end

    # the big enchilada
    # query = "SELECT events.id AS event_id, venues.id AS venue_id
    #     FROM events 
    #       INNER JOIN occurrences ON events.id = occurrences.event_id
    #       INNER JOIN venues ON events.venue_id = venues.id
    #       LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
    #       LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
    #     WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_match} AND #{low_price_match} AND #{high_price_match}
    #     ORDER BY occurrences.start"

    query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id, venues.id AS venue_id
        FROM occurrences 
          INNER JOIN events ON occurrences.event_id = events.id
          INNER JOIN venues ON events.venue_id = venues.id
          LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
          LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
        WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
    
    @ids = ActiveRecord::Base.connection.select_all(query)

    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    @occurrences = Occurrence.includes(:event => :tags, :event => :venue, :event => :occurrences, :event => :recurrences).find(@occurrence_ids)

    # puts query
    # puts ""
    # puts "- - - - - - - - - - - - -"
    # puts ""
    # @occurrences.each { |occ| pp occ }
    # puts ""
    

    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      @occurrences = @occurrences.sort_by do |occurrence| 
        occurrence.event.score
      end.reverse
    else
      @occurrences = @occurrences.sort_by do |occurrence|
        occurrence.start
      end
    end

    # generating tag list for occurrences

    @occurringTags = {}
    @occurrences.each do |occurrence|
      occurrence.event.tags.each do |tag|
        unless(tag.parent_tag_id)
          if(!@occurringTags[tag.id])
            @occurringTags[tag.id] = { :tag => Tag.new(:name => tag.name), :count => 1 }
          else
            @occurringTags[tag.id][:count] += 1
          end
        end
      end
    end

    @occurrences.each do |occurrence|
      occurrence.event.tags.each do |tag|
        unless(!tag.parent_tag_id)
          if(!@occurringTags[tag.id])
            @occurringTags[tag.id] = { :tag => Tag.new(:name => tag.name, :parent_tag_id => tag.parent_tag_id), :count => 1 }
            @occurringTags[tag.id][:tag].id = tag.id
            if(@occurringTags[tag.parent_tag_id])
              @occurringTags[tag.parent_tag_id][:tag].childTags.push(@occurringTags[tag.id][:tag])
            end
          else
            @occurringTags[tag.id][:count] += 1
          end
        end
      end
    end

    tags_list = ((params[:included_tags].to_s.empty?) ? [] : params[:included_tags].collect { |str| str.to_i }) + ((params[:excluded_tags].to_s.empty?) ? [] : params[:excluded_tags].collect { |str| str.to_i })
    tags_list.each do |tag_id|
      tag = Tag.find(tag_id)
      parent_tag = tag.parentTag

      if(parent_tag)
        unless(@occurringTags[parent_tag.id])
          @occurringTags[parent_tag.id] = { :tag => Tag.new(:name => parent_tag.name), :count => 0 }
        end

        unless(@occurringTags[tag.id])
          @occurringTags[tag.id] = { :tag => Tag.new(:name => tag.name, :parent_tag_id => tag.parent_tag_id), :count => 0 }
          @occurringTags[tag.id][:tag].id = tag.id
          @occurringTags[parent_tag.id][:tag].childTags.push(@occurringTags[tag.id][:tag])
        end
      else
        unless(@occurringTags[tag.id])
          @occurringTags[tag.id] = { :tag => Tag.new(:name => tag.name), :count => 0 }
        end
      end
    end

    @occurringTags = Hash[@occurringTags.sort_by { |id, tuple| id }]

    # pp @occurringTags
    # puts ""
    # puts "- - - - - - - - - - - - -"
    # puts ""
    # @occurringTags.each do |id,tuple|
    #   pp tuple[:tag]
    #   pp tuple[:tag].childTags
    # end

    # puts "_________________________"
    # puts ""

    if @event_ids.count > 0
      ActiveRecord::Base.connection.update("UPDATE events
        SET views = views + 1
        WHERE id IN (#{@event_ids * ','})")

      ActiveRecord::Base.connection.update("UPDATE venues
        SET views = views + 1
        WHERE id IN (#{@venue_ids * ','})")
    end

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
    end

    # @events = Event.includes(:tags, :venue, :occurrences, :recurrences).find(@event_ids)

    # @events.each { |event| pp event.occurrences }

    # if(params[:sort].to_s.empty? || params[:sort] == 0)
    #   @events = @events.sort_by do |event| 
    #     event.score
    #   end.reverse
    # else
    #   @events = @events.sort_by do |event|
    #     event.occurrences.first.start
    #   end
    # end

    # if @events.count > 0 
    #   ActiveRecord::Base.connection.update("UPDATE events
    #     SET views = views + 1
    #     WHERE id IN (#{@event_ids * ','})")

    #   ActiveRecord::Base.connection.update("UPDATE venues
    #     SET views = views + 1
    #     WHERE id IN (#{@venue_ids * ','})")
    # end

    # respond_to do |format|
    #   format.html do
    #     unless (params[:ajax].to_s.empty?) 
    #       render :partial => "event_list", :locals => { :events => @events }
    #     end
    #   end
    #   format.json { render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
    # end

  end


  def indexMobile

    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    search_match = occurrence_match = location_match = tag_match = price_match = "TRUE"

    # search
    unless(params[:search].to_s.empty?)
      search = params[:search].gsub(/[^0-9a-z ]/i, '').upcase
      searches = search.split(' ')
      
      search_match_arr = []
      searches.each do |word|
        search_match_arr.push("(upper(venues.name) LIKE '%#{word}%' OR upper(events.description) LIKE '%#{word}%' OR upper(events.title) LIKE '%#{word}%')")
      end

      search_match = search_match_arr * " AND "
    end

    # occurrence
    event_start = (params[:start].to_s.empty? ? Date.today.to_datetime.to_s : Time.at(params[:start].to_i).to_datetime.to_s)
    event_end = Time.at(params[:end].to_s.empty? ? 32513174400 : params[:end].to_i).to_datetime.to_s
    event_days = params[:day].to_s.empty? ? nil : params[:day]

    occurrence_match = "occurrences.start >= '#{event_start}' AND occurrences.start <= '#{event_end}' AND #{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    
    # location
    if(params[:lat_min].to_s.empty? || params[:long_min].to_s.empty? || params[:lat_max].to_s.empty? || params[:long_max].to_s.empty?)
      @ZoomDelta = {
               11 => { :lat => 0.30250564 / 2, :long => 0.20942688 / 2 }, 
               13 => { :lat => 0.0756264644 / 2, :long => 0.05235672 / 2 }, 
               14 => { :lat => 0.037808182 / 2, :long => 0.02617836 / 2 }
              }
      # # 30.268037,-97.742722
      @lat = 30.268093
      @long = -97.742808
      @zoom = 11

      unless params[:location].to_s.empty?
        json_object = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + URI::encode(params[:location])).read)
        unless (json_object.nil? || json_object["results"].length == 0)

          @lat = json_object["results"][0]["geometry"]["location"]["lat"]
          @long = json_object["results"][0]["geometry"]["location"]["lng"]
          # if the results are of a city, keep it zoomed out aways
          if (json_object["results"][0]["address_components"][0]["types"].index("locality").nil?)
            @zoom = 14
          end
        end
      end

      @lat_delta = @ZoomDelta[@zoom][:lat]
      @long_delta = @ZoomDelta[@zoom][:long]
      @lat_min = @lat - @lat_delta
      @lat_max = @lat + @lat_delta
      @long_min = @long - @long_delta
      @long_max = @long + @long_delta
    else
      @lat_min = params[:lat_min]
      @lat_max = params[:lat_max]
      @long_min = params[:long_min]
      @long_max = params[:long_max]
    end

    location_match = "venues.id = events.venue_id AND venues.latitude >= #{@lat_min} AND venues.latitude <= #{@lat_max} AND venues.longitude >= #{@long_min} AND venues.longitude <= #{@long_max}"

    # tags
    unless(params[:tags].to_s.empty?)
      @tagIDs = params[:tags].split(",").collect { |str| str.to_i }
      tag_match = "events.id IN (
                    SELECT event_id 
                      FROM events, tags, events_tags 
                      WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{params[:tags]}) 
                      GROUP BY event_id 
                      HAVING COUNT(tag_id) >= #{@tagIDs.count}
                  )"
    end

    # price
    unless(params[:price].to_s.empty?)
      price_match_arr = []
      
      price_ranges = [0,0.01,10,25,50]
      @prices = params[:price].split(",").collect { |str| str.to_i }
      @prices.each do |i|
        price_match_arr.push("events.price >= #{price_ranges[i]} AND #{ (i == price_ranges.length - 1) ? "TRUE" : "events.price < " + price_ranges[i+1].to_s }")
      end
      price_match = price_match_arr * " OR "
      price_match = "(" + price_match + ")"
    end

    # the big enchilada
    @ids = ActiveRecord::Base.connection.select_all("
      SELECT events.id AS event_id, venues.id AS venue_id
        FROM events 
          INNER JOIN occurrences ON events.id = occurrences.event_id
          INNER JOIN venues ON events.venue_id = venues.id
          LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
          LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
        WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_match} AND #{price_match}
        ORDER BY occurrences.start")

    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    @events = Event.includes(:tags, :venue, :occurrences, :recurrences).find(@event_ids)

    if(params[:sort].to_s.empty? || params[:sort] == 0)
      @events = @events.sort_by do |event| 
        event.score
      end.reverse
    end

    if @events.count > 0 
      ActiveRecord::Base.connection.update("UPDATE events
        SET views = views + 1
        WHERE id IN (#{@event_ids * ','})")

      ActiveRecord::Base.connection.update("UPDATE venues
        SET views = views + 1
        WHERE id IN (#{@venue_ids * ','})")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
      format.mobile { render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
    end

   

  end

  # GET /events/1
  # GET /events/1.json
  def show
    @occurrence = Occurrence.find(params[:id])
    @event = @occurrence.event

    @event.clicks += 1
    @event.save

    @occurrences = []
    @recurrences = []
    @event.occurrences.each do |occ|
      # check if occurrence is instance of a recurrence
      if occ.recurrence_id.nil? && occ.id != @occurrence.id
        @occurrences << occ
      else
        if occ.recurrence && @recurrences.index(occ.recurrence).nil?
          @recurrences << occ.recurrence
        end
      end
    end
    respond_to do |format|
      format.html { render :layout => "mode" }
      format.json { render json: @event.to_json(:include => [:occurrences, :venue]) }
      format.mobile { render json: @event.to_json(:include => [:occurrences, :venue]) }
    end
  end

  def shunt
    respond_to do |format|
      format.html { render :layout => "mode_lite" }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    #@venues = Venue.all
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    #@venues = Venue.all
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @occurrence = Occurrence.new(:start => params[:start], :end => params[:end], :event_id => @event.id)
    puts params[:start]
    puts params[:end]
    respond_to do |format|
      if @event.save && @occurrence.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end
  
end
