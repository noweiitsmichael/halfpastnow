require 'pp'
require 'open-uri'
require 'json'
include Yelp::V1::Review::Request
require 'will_paginate/array'
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
  helper :content

  def splash
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def filter

  end

  def new_splash
    lat = 30.268093
    long = -97.742808
    zoom = 11

    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom
    if current_user
      params[:user_id] = current_user ? current_user.id : nil
      ids = Occurrence.find_with(params)
      occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq
      order_by = "occurrences.start"

      @occurrences =  Occurrence.includes(:event => :tags).find(occurrence_ids, :order => order_by).take(5)
      @advertisement = Advertisement.where(:placement => ['home_page', 'home_search_pages'] ).where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first
      @advertisement.update_attributes(views: (@advertisement.views.to_i + 1)) unless @advertisement.nil?

      @saved_searches = current_user.saved_searches  if user_signed_in?
      @austin_occurrences =  BookmarkList.find(2370).bookmarked_events_root.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time }.sort_by { |o| o.start }.take(5)
    end

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def new_email
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def android
    puts "Inside android controller !!!!!"

    @lat = 30.268093
    @long = -97.742808
    @zoom = 11

    params[:lat_center] = @lat
    params[:long_center] = @long
    params[:zoom] = @zoom

    params[:user_id] = current_user ? current_user.id : nil

    @message =""
    puts "Params SSSSSSSXSW : "
    puts params
    if params[:type].to_s.eql? "sxsw"
      channel_ms="I have a badge with Free Food, Free Drinks, Party, Unofficial events during SXSW. "
      if params[:channel_id].to_i == 414
        channel_ms = "I have a badge "
      elsif params[:channel_id].to_i.to_i == 415
        channel_ms = "I have a wristband "
      elsif params[:channel_id].to_i == 416
        channel_ms = "I have NO SXSW Credentials "
      elsif params[:channel_id].to_i == 424
        channel_ms = "I have nothin' but my cowboy boots on "
      end
      # puts channel_ms
      tag = (params[:included_tags].to_s.empty?) ? [] : params[:included_tags].split(",")
      # puts "tags - 0"
      # puts params
      # puts tag
      # puts params[:included_tags]
      tag_ms =""
      i=0
      tag.each { |t|
        # puts "tags"
        s = t.to_s
        # puts s

        if s.eql? "166"
          tag_ms = (i==0) ? "with Free Drinks" : tag_ms.concat(", Free Drinks")
        elsif s.eql? "165"
          tag_ms = (i==0) ? "with Free Food" : tag_ms.concat(", Free Food")
        elsif s.eql? "184"
          tag_ms = (i==0) ? "with Party" : tag_ms.concat(", Party")
        elsif s.eql? "167"
          tag_ms = (i==0) ? "with No Cover" : tag_ms.concat(", No Cover")
        elsif s.eql? "191"
          tag_ms = (i==0) ? "with RSVP" : tag_ms.concat(", RSVP")
        elsif s.eql? "189"
          tag_ms = (i==0) ? "with Unofficial Events" : tag_ms.concat(", Unofficial Events")
        end
        i=i+1
      }
      # puts "Tags - combine: "
      # puts tag_ms
      time_ms =""
      if params[:t].to_s.eql? "0"
        time_ms = " SXSW "
      elsif params[:t].to_s.eql? "1"
        time_ms = " Today "
      else
        time_ms = (params[:start_date].to_s.eql? "") ? "" : " From ".concat(params[:start_date].to_s.concat(" to ".concat(params[:end_date].to_s)))
      end


      sort_ms =""
      unless params[:sort].to_s.empty?
        if params[:sort].to_i == 0
          sort_ms = " and sort by most views"
        elsif params[:sort].to_i == 1
          sort_ms = " and sort by date"
        end
      end

      @message = channel_ms.concat(tag_ms).concat(time_ms.concat(sort_ms))
    else
      @message ="Your filter - All categories - No time limit - No cost limit "
      mod = "Your filter - All categories - No time limit - No cost limit "
      @tag = (params[:included_tags].to_s.empty?) ? [] : params[:included_tags].split(",").uniq
      @tag=@tag.join(",")
      if @tag.size >0
        names = Tag.where("ID in (#{@tag})").collect { |t| t.name }.join(",")

        @message = "Your filter - ".concat(names)
      end

      @tag = (params[:and_tags].to_s.empty?) ? [] : params[:and_tags].split(",").uniq
      @tag=@tag.join(",")
      if @tag.size >0
        names = Tag.where("ID in (#{@tag})").collect { |t| t.name }.join(",")

        @message = (@message.eql? mod) ? "Your filter - ".concat(names) : @message.concat(" with ".concat(names))
      end

      time = (params[:time].to_s.empty?) ? "" : params[:time].to_s
      unless time.eql? ""
        @message = (@message.eql? mod) ? "Your filter - during ".concat(time) : @message.concat(" during ".concat(time))
      end
      cost = (params[:high_price].to_s.empty?) ? "" : params[:high_price].to_s
      if cost.eql? "0"
        @message = (@message.eql? mod) ? "Your filter - with cost Free" : @message.concat(" Free")

      elsif cost.eql? "10"
        @message = (@message.eql? mod) ? "Your filter - with cost <$10" : @message.concat(" <$10")
      elsif cost.eql? "20"
        @message = (@message.eql? mod) ? "Your filter - with cost <$20" : @message.concat(" <$20")

      elsif cost.eql? "777777777"
        @message = (@message.eql? mod) ? "Your filter - with No Price limit" : @message.concat(" No Price Limit")

      end

      if params[:sort].to_s.eql? "0"
        @message = (@message.eql? mod) ? "Your filter - all events sorted by Most Views" : @message.concat(" Sort by Most Views")
      else
        @message = (@message.eql? mod) ? "Your filter - all events sorted by Date" : @message.concat(" Sort by Date")
      end

    end
    unless params[:days].to_s.empty?
      params[:day] = ["0", "6"]
    end

    puts @message

    @ids = Occurrence.find_with(params)


    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq

    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    order_by = "occurrences.start"
    if (params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select { |tag| tag.parentTag.nil? }

    @amount = 20
    unless (params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless (params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end
    @allOccurrences = Occurrence.find(@occurrence_ids)
    #@occurrences = Occurrence.paginate(:page => params[:page], :per_page => 10).includes(:event => :tags).find(@occurrence_ids, :order => order_by)
    @occurrences = Occurrence.includes(:event => :tags).find(@occurrence_ids, :order => order_by)


    # puts @occurrences  

    # puts @occurrences
    @occurringTags = {}

    @tagCounts = []

    @parentTags.each do |parentTag|
      @tagCounts[parentTag.id] = {
        :count => 0,
        :children => [],
        :id => parentTag.id,
        :name => parentTag.name,
        :parent => nil
      }
      parentTag.childTags.each do |childTag|
        @tagCounts[childTag.id] = {
          :count => 0,
          :children => [],
          :id => childTag.id,
          :name => childTag.name,
          :parent => @tagCounts[parentTag.id]
        }
        @tagCounts[parentTag.id][:children].push(@tagCounts[childTag.id])
      end
    end

    @allOccurrences.each do |occurrence|
      occurrence.event.tags.each do |tag|
        @tagCounts[tag.id][:count] += 1
      end
    end

    @parentTags.each do |parentTag|
      @tagCounts[parentTag.id][:children] = @tagCounts[parentTag.id][:children].sort_by { |tagCount| tagCount[:count] }.reverse
    end

    @tagCounts = @tagCounts.sort_by { |tagCount| tagCount ? tagCount[:count] : 0 }.compact.reverse

    if @event_ids.size > 0
      ActiveRecord::Base.connection.update("UPDATE events
        SET views = views + 1
        WHERE id IN (#{@event_ids * ','})")

      ActiveRecord::Base.connection.update("UPDATE venues
        SET views = views + 1
        WHERE id IN (#{@venue_ids * ','})")
    end

    @last= 'Last message'
    @filter =params

    # Badge
    @badge = params[:access].to_s
    @t = params[:t].to_s
    @arrayincluded_tags = (params[:included_tags].to_s.empty?) ? [] : params[:included_tags].to_s.split(",")
    @arrayincluded_tags=(params[:included_tags].to_s.empty?) ? [] : params[:included_tags].map(&:to_s)
    @s = params[:sort].to_s

    # Advance
    @arrayand_tags = (params[:and_tags].to_s.empty?) ? [] : params[:and_tags].to_s.split(",")
    @arrayand_tags=(params[:and_tags].to_s.empty?) ? [] : params[:and_tags].map(&:to_s)
    @aday=params[:aday].to_s
    @acost = params[:c].to_s
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "android_combo", :locals => {:filter => params, :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags, :offset => @offset}

        end
      end
      format.json { render json: @occurrences.to_json(:include => {:event => {:include => [:tags, :venue, :acts]}}) }
      format.mobile
    end

  end

  def index
    params[:start_date] = "#{Date.today().to_s(:db)}" if (params[:start_date] == "" or !params[:start_date].present?)
    params[:end_date] = "#{(Date.today()+14.days).to_s(:db)}" if (params[:end_date] == "" or !params[:end_date].present?)
    @saved_search = current_user.saved_searches if user_signed_in?

    #ads
    @advertisement = Advertisement.where(:adv_type => ["featured_venue", "featured_event", "featured_artist"]).where(:placement => ['search_results', 'home_search_pages']).where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first
    @banner_advertisement = Advertisement.where(:adv_type => ["banner_ads"]).where(:placement => Advertisement::ADV_PLACEMENTS[:banner].map{|a| a.last}).where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first

    unless params[:root]
      @advertisement.update_attributes(views: (@advertisement.views.to_i + 1)) unless @advertisement.nil?
      @banner_advertisement.update_attributes(views: (@banner_advertisement.views.to_i + 1)) unless @banner_advertisement.nil?
    end
    # Set default if action is sxsw
    unless (params[:event_id].to_s.empty?)
     # redirect_to :action => "show", :id => params[:event_id].to_i, :fullmode => true
    end


    unless (params[:venue_id].to_s.empty?)
     # redirect_to :action => "show", :controller => "venues", :id => params[:venue_id].to_i, :fullmode => true
    end

    unless (params[:act_id].to_s.empty?)
     # redirect_to :action => "show", :controller => "acts", :id => params[:act_id].to_i, :fullmode => true
    end

    if (@mobileMode)
      @switch ="advance"
      unless params[:format].to_s.eql? "mobile"
        redirect_to :action => "android", :type => "advance"
      else
        return
      end

    end

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select { |tag| tag.parentTag.nil? }

    @amount = 20
    unless (params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless (params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end


    # unless current_user.uid.nil?
    #   @graph = current_user.facebook

    #   profile = @graph.get_object("me")
    #   puts "current_user info"
    #   my_fql_query ="select uid, name from user where is_app_user = 1 and uid in (SELECT uid2 FROM friend WHERE uid1 = me())"
    #   fql = @graph.fql_query(my_fql_query)

    #   puts fql

    # end

    @lat = 30.268093
    @long = -97.742808
    @zoom = 11

    params[:lat_center] = @lat
    params[:long_center] = @long
    params[:zoom] = @zoom

    params[:user_id] = current_user ? current_user.id : nil
    @ids = Occurrence.find_with(params)

    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    order_by = "occurrences.start"


    @allOccurrences = Occurrence.includes(:event => :tags).find(@occurrence_ids, :order => order_by)
    if params[:filter_type] == "neighborhood" and params[:neighborhood_id].present?
      neighborhood = Neighborhood.find params[:neighborhood_id]
      p neighborhood
      @occurrences = neighborhood.occurrences.select{|k| @allOccurrences.map(&:id).include?(k.id)}#.page(1).per_page(21)
    end
    if params[:cost_sort] == "cost"
      @occurrences = @allOccurrences.sort_by { |o| params[:order_cost].to_i*o.event.price.to_f }.paginate(:page => params[:page], :per_page => 21)
    elsif params[:time_sort] == "time"
      if params[:order_time] == "1"
        @occurrences = @allOccurrences.sort_by{|o| o.start}.paginate(:page => params[:page], :per_page => 21)
      elsif params[:order_time] == "-1"
        @occurrences = @allOccurrences.sort_by{|o| o.start}.reverse!
        @occurrences = @occurrences.paginate(:page => params[:page], :per_page => 21)
      end
    else
      @occurrences = @allOccurrences.paginate(:page => params[:page], :per_page => 21)
    end

    # generating tag list for occurrences

    @occurringTags = {}

    @tagCounts = []

    @parentTags.each do |parentTag|
      @tagCounts[parentTag.id] = {
        :count => 0,
        :children => [],
        :id => parentTag.id,
        :name => parentTag.name,
        :parent => nil
      }
      parentTag.childTags.each do |childTag|
        @tagCounts[childTag.id] = {
          :count => 0,
          :children => [],
          :id => childTag.id,
          :name => childTag.name,
          :parent => @tagCounts[parentTag.id]
        }
        @tagCounts[parentTag.id][:children].push(@tagCounts[childTag.id])
      end
    end

    @allOccurrences.each do |occurrence|
      occurrence.event.tags.each do |tag|
        @tagCounts[tag.id][:count] += 1
      end
    end

    # neighborhoods
    unless params[:root]
      @all_neighborhoods = Neighborhood.order("name asc")
    end


    @parentTags.each do |parentTag|
      @tagCounts[parentTag.id][:children] = @tagCounts[parentTag.id][:children].sort_by { |tagCount| tagCount[:count] }.reverse
    end

    @tagCounts = @tagCounts.sort_by { |tagCount| tagCount ? tagCount[:count] : 0 }.compact.reverse

    if @event_ids.size > 0
      ActiveRecord::Base.connection.update("UPDATE events
        SET views = views + 1
        WHERE id IN (#{@event_ids * ','})")

      ActiveRecord::Base.connection.update("UPDATE venues
        SET views = views + 1
        WHERE id IN (#{@venue_ids * ','})")
    end
     @location = "search"
    @austin_occurrences = BookmarkList.find(2370).all_bookmarked_events.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time }.sort_by { |o| o.start } if params[:root]
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)

        params[:root]? @occurrences = @occurrences.take(5):@occurrences = @occurrences

          @root_page = params[:root]? params[:root]:nil
          #raise "number of occurrences: #{@occurrences.count}, occurrences tags: #{@occurringTags.count},parent tags:#{@parentTags.count},offset value:#{@offset}"
          render :partial => "combo", :locals => {:occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags, :offset => @offset,:root_page => @root_page}

        end
      end
      format.json { render json: @occurrences.to_json(:include => {:event => {:include => [:tags, :venue, :acts]}}) }
      format.mobile
      format.js
    end

  end

  # GET /events/1
  # GET /events/1.json
  def show

    @occurrence = Occurrence.find(params[:id])
    @event = @occurrence.event
    near_by_venues = @event.venue.nearbys(1)
    near_by_venue_ids=near_by_venues.nil??  (Venue.near(@event.venue.city,1).map(&:id)):near_by_venues.map(&:id)
    params[:user_id] = current_user ? current_user.id : nil
    ids = Occurrence.find_with(params)
    occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"
    @related_occurrences = Occurrence.includes(:event => :tags).find(occurrence_ids, :order => order_by)
    event_ids = @related_occurrences.collect { |e| e["event_id"] }.uniq
    near_by_event_ids = event_ids.select{|e| (near_by_venue_ids.include?(Event.find(e).venue.id) if Event.find(e).venue.id )}
    @near_by_occurrences = @related_occurrences.select{|o| (near_by_venue_ids.include?(o.event.venue.id))}.take(4)
    @near_by_events=near_by_event_ids.collect{|e| Event.find(e)}.take(4)
    @all_occurrences = @related_occurrences.take(9)
    # begin
    puts "Share content"
    params[:fullmode] = true
    @fullmode = (!params[:fullmode].to_s.empty?) || (@mobileMode)
    @modeType = "event"


    @pageTitle = @event.title + " | half past now."

    @event.clicks += 1
    @event.save

    #ads
    @advertisement = Advertisement.where(:placement => 'details').where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first
    @advertisement.update_attributes(views: (@advertisement.views.to_i + 1)) unless @advertisement.nil?


    if (current_user)
      @bookmarks = Bookmark.where(:bookmarked_type => 'Occurrence', :bookmarked_id => @occurrence.id, :bookmark_list_id => current_user.bookmark_lists.collect(&:id))
      attending = Bookmark.where(:bookmarked_type => 'Occurrence', :bookmarked_id => @occurrence.id, :bookmark_list_id => current_user.bookmark_lists.where(:name => "Attending").first.id).first
      @bookmark_lists_ids = @bookmarks.empty? ? [0] : @bookmarks.collect(&:bookmark_list_id)
      #@bookmarks = bookmarks.empty? ? [] : bookmark.id
      @attendingId = attending.nil? ? nil : attending.id
      # bookmarkFeaturedList=Bookmark.where(:bookmarked_type => "Occurrence",:bookmark_list_id => current_user.featured_list.id, :bookmarked_id =>@occurrence.id).first
      bookmarkFeaturedList=(!current_user.featured_list.nil?) ? @occurrence.all_event_bookmarks(current_user.featured_list.id).first : nil
      @bookmarkFeaturedListId = bookmarkFeaturedList.nil? ? nil : bookmarkFeaturedList.id
    else
      @bookmarkId = nil
      @attendingId = nil
      @bookmarkFeaturedListId = nil
    end

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
    # http://secret-citadel-5147.herokuapp.com/events/show/11?fullmode=true
    @url ='http://www.halfpastnow.com/?event_id='+params[:id]
    @url1="http://www.halfpastnow.com/events/austin/#{@occurrence.slug}"
    @ur = 'https://www.facebook.com/plugins/like.php?href=http://www.halfpastnow.com/mobile/og/'+params[:id]

    # http://www.halfpastnow.com/?event_id=15599
    # @url= 'http://secret-citadel-5147.herokuapp.com/mobile/og/8'
    @attending_friends = current_user.friends.select{|f| f.bookmarks.map(&:bookmarked_id).include?(@occurrence.id)} rescue nil
    respond_to do |format|

        format.html { render :layout => "fullmode" }



      format.json { render json: @event.to_json(:include => [:occurrences, :venue]) }
      # format.mobile { render json: @event.to_json(:include => [:occurrences, :venue]) }
      format.mobile
    end
    # raise current_user.friends.map(&:id).inspect

     #raise @attending_friends.inspect
    #rescue
    #  respond_to do |format|
    #    format.js { render template: "events/error_show" }
    # # end
    #  end
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
    # puts params[:start]
    # puts params[:end]
    respond_to do |format|
      if @event.save && @occurrence.save
        @event.completion = @event.completedness
        @event.save
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
        @event.completion = @event.completedness
        @event.save

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

  def upcoming
    puts "upcoming....."
    if params[:range] == "oneweek"
      # @eventsList = Event.find(:all).map(&:nextOccurrence.to_proc).reject {|x| x.nil?}.delete_if { |x| x.start > 1.week.from_now}
      # @eventsList = Event.find(:all, :conditions => ["(start > ?) AND (start < ?)", Time.now, 1.week.from_now])

      eventsQuery = "
        SELECT occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id
        FROM occurrences, events WHERE occurrences.event_id = events.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NULL 
             AND occurrences.start < now() + interval '1 week' AND occurrences.start >= now() 
        UNION 
        SELECT DISTINCT ON (occurrences.recurrence_id) occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id
        FROM occurrences, events WHERE occurrences.event_id = events.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NOT NULL
             AND occurrences.start < now() + interval '1 week' AND occurrences.start >= now()"
      @eventsList = ActiveRecord::Base.connection.select_all(eventsQuery)
    else
      params[:range] == "twoweeks"
      # @eventsList = Event.find(:all).map(&:nextOccurrence.to_proc).reject {|x| x.nil?}.delete_if { |x| x.start > 2.week.from_now}
      eventsQuery = "
        SELECT occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id
        FROM occurrences, events WHERE occurrences.event_id = events.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NULL 
             AND occurrences.start < now() + interval '2 weeks' AND occurrences.start >= now() 
        UNION 
        SELECT DISTINCT ON (occurrences.recurrence_id) occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id
        FROM occurrences, events WHERE occurrences.event_id = events.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NOT NULL
             AND occurrences.start < now() + interval '2 weeks' AND occurrences.start >= now()"
      @eventsList = ActiveRecord::Base.connection.select_all(eventsQuery)
    end
    @outputList = []

    @eventsList.each do |e|
      unless e["event_id"].nil?
        # @outputList << {'id' => e.id, 'event_id' => e.event.id, 'event_title' => e.event.title,  'event_completedness' => e.event.completedness, 'venue_id' => e.event.venue.id, 'start' => e.start.strftime("%m/%d @ %I:%M %p"), 'owner' => User.where(:id => e.event.user_id).exists? ? User.find(e.event.user_id).fullname : "", 'updated_at' => e.event.updated_at.strftime("%m/%d @ %I:%M %p")}
        @outputList << {'id' => e["id"], 'event_id' => e["event_id"], 'event_title' => e["title"], 'event_completedness' => e["completion"], 'venue_id' => e["venue_id"], 'start' => Time.parse(e["start"]).strftime("%m/%d @ %I:%M %p"), 'owner' => User.where(:id => e["user_id"]).exists? ? User.find(e["user_id"]).fullname : "", 'updated_at' => Time.parse(e["updated_at"]).strftime("%m/%d @ %I:%M %p")}
      end
    end
    respond_to do |format|
      format.json { render json: @outputList }
    end
  end

  def upcoming_user_input
    puts "upcoming user input evets...."

    eventsQuery = "
      SELECT occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id, users.role, users.firstname, users.lastname
      FROM occurrences, events, users 
      WHERE occurrences.event_id = events.id AND events.user_id = users.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NULL 
           AND occurrences.start < now() + interval '4 weeks' AND occurrences.start >= now() AND users.role NOT IN ('super_admin', 'admin', 'old_admin')
      UNION 
      SELECT DISTINCT ON (occurrences.recurrence_id) occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id, users.role, users.firstname, users.lastname
      FROM occurrences, events, users 
      WHERE occurrences.event_id = events.id AND events.user_id = users.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NOT NULL AND users.role NOT IN ('super_admin', 'admin', 'old_admin')
           AND occurrences.start < now() + interval '4 weeks' AND occurrences.start >= now()"
    @eventsList = ActiveRecord::Base.connection.select_all(eventsQuery)

    @outputList = []

    @eventsList.each do |e|
      unless e["event_id"].nil?
        # @outputList << {'id' => e.id, 'event_id' => e.event.id, 'event_title' => e.event.title,  'event_completedness' => e.event.completedness, 'venue_id' => e.event.venue.id, 'start' => e.start.strftime("%m/%d @ %I:%M %p"), 'owner' => User.where(:id => e.event.user_id).exists? ? User.find(e.event.user_id).fullname : "", 'updated_at' => e.event.updated_at.strftime("%m/%d @ %I:%M %p")}
        @outputList << {'id' => e["id"], 'event_id' => e["event_id"], 'event_title' => e["title"], 'event_completedness' => e["completion"], 'venue_id' => e["venue_id"], 'start' => Time.parse(e["start"]).strftime("%m/%d @ %I:%M %p"), 'owner' => User.where(:id => e["user_id"]).exists? ? User.find(e["user_id"]).fullname : "", 'owner_id' => e["user_id"], 'updated_at' => Time.parse(e["updated_at"]).strftime("%m/%d @ %I:%M %p")}
      end
    end
    respond_to do |format|
      format.json { render json: @outputList }
    end
  end


  def venuesTable
    venuesQuery = "
      SELECT v2.venue_id, v2.name, v2.address, v2.views, v2.events_count, COALESCE(v1.raw_events_count, 0) AS raw_events_count, v2.assigned_admin, v2.firstname, v2.lastname FROM
        ( SELECT venue_id,venues.name,COUNT(*) AS raw_events_count
          FROM venues,raw_venues,raw_events 
          WHERE venues.id = raw_venues.venue_id AND raw_venues.id = raw_events.raw_venue_id AND raw_events.submitted IS NULL AND raw_events.deleted IS NULL AND raw_events.start > now()
          GROUP BY venue_id,venues.name ) v1
      FULL OUTER JOIN
        ( SELECT venues.id AS venue_id, venues.name, venues.address, venues.views, COUNT(events.id) AS events_count, venues.assigned_admin, users.firstname, users.lastname
          FROM venues
          LEFT OUTER JOIN
            ( SELECT events.id, events.venue_id, min(occurrences.start)
              FROM events
              LEFT OUTER JOIN occurrences
              ON events.id = occurrences.event_id
              WHERE occurrences.start > now() AND occurrences.deleted IS NOT true
              GROUP BY events.id) AS events
          ON venues.id = events.venue_id
          LEFT JOIN users ON venues.assigned_admin = users.id
          GROUP BY venues.id,venues.name, users.id ) v2
      ON v1.venue_id = v2.venue_id"

    @venuesList = ActiveRecord::Base.connection.select_all(venuesQuery)

    @outputList = []

    @venuesList.each do |e|
      @outputList << {'id' => e["venue_id"], 'name' => e["name"], 'address' => e["address"], 'views' => e["views"], 'num_events' => e["events_count"], 'num_raw_events' => e["raw_events_count"], 'firstname' => (e["firstname"] == nil ? "" : e["firstname"]), 'lastname' => (e["lastname"] == nil ? "" : e["lastname"])} #, 'owner' => User.where(:id => e["user_id"]).exists? ? User.find(e["user_id"]).fullname : ""}
    end

    respond_to do |format|
      format.json { render json: @outputList }
    end
  end

  def sxsw_list
    puts "sxsw....."
    if params[:range] == "raw_sxsw"
      # @eventsList = Event.find(:all).map(&:nextOccurrence.to_proc).reject {|x| x.nil?}.delete_if { |x| x.start > 1.week.from_now}
      # @eventsList = Event.find(:all, :conditions => ["(start > ?) AND (start < ?)", Time.now, 1.week.from_now])

      eventsQuery = "
        SELECT raw_events.id, raw_events.title,raw_events.start,raw_events.from,raw_events.raw_id, raw_events.raw_venue_id, venues.id AS venue_id, venues.name AS venue_name
          FROM raw_events, raw_venues, venues
          WHERE raw_events.raw_venue_id = raw_venues.id AND raw_venues.venue_id = venues.id AND (raw_events.from = 'eventbrite' OR raw_events.from = 'do512sxsw' OR raw_events.from = 'sched') AND raw_events.deleted IS NOT TRUE AND raw_events.submitted IS NOT TRUE"
      @eventsList = ActiveRecord::Base.connection.select_all(eventsQuery)
    else
      params[:range] == "active_sxsw"
      # @eventsList = Event.find(:all).map(&:nextOccurrence.to_proc).reject {|x| x.nil?}.delete_if { |x| x.start > 2.week.from_now}
      eventsQuery = "
        SELECT occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id
        FROM occurrences, events WHERE occurrences.event_id = events.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NULL 
             AND occurrences.start < now() + interval '2 weeks' AND occurrences.start >= now() 
        UNION 
        SELECT DISTINCT ON (occurrences.recurrence_id) occurrences.recurrence_id, occurrences.id, events.id AS event_id, events.title, events.completion, events.venue_id, occurrences.start, events.updated_at, events.user_id
        FROM occurrences, events WHERE occurrences.event_id = events.id AND occurrences.deleted = false AND occurrences.recurrence_id IS NOT NULL
             AND occurrences.start < now() + interval '2 weeks' AND occurrences.start >= now()"
      @eventsList = ActiveRecord::Base.connection.select_all(eventsQuery)
    end

    @outputList = []

    @eventsList.each do |e|
      unless e["id"].nil?
        # @outputList << {'id' => e.id, 'event_id' => e.event.id, 'event_title' => e.event.title,  'event_completedness' => e.event.completedness, 'venue_id' => e.event.venue.id, 'start' => e.start.strftime("%m/%d @ %I:%M %p"), 'owner' => User.where(:id => e.event.user_id).exists? ? User.find(e.event.user_id).fullname : "", 'updated_at' => e.event.updated_at.strftime("%m/%d @ %I:%M %p")}
        @outputList << {'id' => e["id"], 'raw_venue_id' => e["raw_venue_id"], 'name' => e["venue_name"], 'venue_id' => e["venue_id"], 'title' => e["title"], 'from' => e["from"], 'start' => Time.parse(e["start"]).strftime("%m/%d @ %I:%M %p")}
      end
    end
    # pp @outputList
    respond_to do |format|
      format.json { render json: @outputList }
    end
  end

  def sxsw

    unless params[:event_id].nil?
      @ur = 'http://www.halfpastnow.com/mobile/og/'+params[:event_id].to_s
    end

    unless (params[:event_id].to_s.empty?)
      redirect_to :action => "show", :id => params[:event_id].to_i, :fullmode => true
    end

    unless (params[:venue_id].to_s.empty?)
      redirect_to :action => "show", :controller => "venues", :id => params[:venue_id].to_i, :fullmode => true
    end

    unless (params[:act_id].to_s.empty?)
      redirect_to :action => "show", :controller => "acts", :id => params[:act_id].to_i, :fullmode => true
    end
    if (@mobileMode)
      puts "in SXSW controller & @mobileMode"
      puts params[:format].to_s
      @switch ="sxsw"

      redirect_to :action => "android", :type => "sxsw"
      return

    end
    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select { |tag| tag.parentTag.nil? }

    @amount = 20
    unless (params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless (params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end

    # 30.268093,-97.742808
    @lat = 30.268093
    @long = -97.742808
    @zoom = 11

    params[:lat_center] = @lat
    params[:long_center] = @long
    params[:zoom] = @zoom

    params[:user_id] = current_user ? current_user.id : nil

    @ids = Occurrence.find_with(params)

    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    order_by = "occurrences.start"
    if (params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end

    @allOccurrences = Occurrence.includes(:event => :tags).find(@occurrence_ids, :order => order_by)
    @occurrences = @allOccurrences.drop(@offset).take(@amount)

    # generating tag list for occurrences

    @occurringTags = {}

    @tagCounts = []

    @parentTags.each do |parentTag|
      @tagCounts[parentTag.id] = {
        :count => 0,
        :children => [],
        :id => parentTag.id,
        :name => parentTag.name,
        :parent => nil
      }
      parentTag.childTags.each do |childTag|
        @tagCounts[childTag.id] = {
          :count => 0,
          :children => [],
          :id => childTag.id,
          :name => childTag.name,
          :parent => @tagCounts[parentTag.id]
        }
        @tagCounts[parentTag.id][:children].push(@tagCounts[childTag.id])
      end
    end

    @allOccurrences.each do |occurrence|
      occurrence.event.tags.each do |tag|
        @tagCounts[tag.id][:count] += 1
      end
    end

    @parentTags.each do |parentTag|
      @tagCounts[parentTag.id][:children] = @tagCounts[parentTag.id][:children].sort_by { |tagCount| tagCount[:count] }.reverse
    end

    @tagCounts = @tagCounts.sort_by { |tagCount| tagCount ? tagCount[:count] : 0 }.compact.reverse

    if @event_ids.size > 0
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
          # render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags, :offset => @offset }
          render :partial => "combo_sxsw", :locals => {:occurrences => @occurrences, :tagCounts => @tagCounts, :parentTags => @parentTags, :offset => @offset}
        end
      end
      format.json { render json: @occurrences.to_json(:include => {:event => {:include => [:tags, :venue, :acts]}}) }
      format.mobile
    end

  end

  def saved_search
    key = current_user.saved_searches.where(:search_key => params[:key].gsub("_"," "))
    if key.empty?
      saved_search = current_user.saved_searches.new
      saved_search.search_key = params[:key]
      saved_search.tag_id = params[:tag_id]
      saved_search.tag_type = params[:tag_type]
      saved_search.save
      @key_id = saved_search.id
    else
      @key_id = (key.id rescue nil)
    end

    flash[:notice] = "Search is saved successfully"
    @key_id.nil? ? (render :nothing => true) : (render :json => {key_id: @key_id})
  end

  def delete_saved_search
    SavedSearch.find(params[:key_id]).delete
    render :nothing => true
  end
  def saved_searches_index

  end
  def login
    unless current_user.nil?
      redirect_to cookies[:url]
    end
  end
  def joinnow
    unless current_user.nil?
      redirect_to cookies[:url]
    end
  end
  def search_results
    @lat = 30.268093
    @long = -97.742808
    @zoom = 11
    params[:lat_center] = @lat
    params[:long_center] = @long
    params[:zoom] = @zoom
    params[:user_id] = current_user ? current_user.id : nil
    if params[:tag_type] == "today"
      params[:start_date] = "#{Date.today().to_s(:db)}"
      params[:end_date] = "#{(Date.today()).to_s(:db)}"
    elsif params[:tag_type] == "crowd"

      params[:start_date] = "#{Date.today().to_s(:db)}" if (params[:start_date] == "" or !params[:start_date].present?)
      params[:end_date] = "#{(Date.today()+14.days).to_s(:db)}" if (params[:end_date] == "" or !params[:end_date].present?)

    elsif params[:tag_type] == "tomorrow"
      params[:start_date] = "#{(Date.today+1.day).to_s(:db)}"
      params[:end_date] = "#{(Date.today+1.day).to_s(:db)}"
    elsif params[:tag_type] == "weekend"
      params[:start_date] = "#{(Date.today.end_of_week-2.days).to_s(:db)}"
      params[:end_date] = "#{Date.today.end_of_week.to_s(:db)}"
    else
    params[:start_date] = "#{DateTime.now().to_s(:db)}" if (params[:start_date] == "" or !params[:start_date].present?)
    params[:end_date] = "#{(DateTime.now()+14.days).to_s(:db)}" if (params[:end_date] == "" or !params[:end_date].present?)
    end
    #raise params.inspect
    @ids = Occurrence.find_with(params)

    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    p "occurrence ids :"
    p @occurrence_ids
    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq
    @occurrences =[]
    order_by = "occurrences.start"
    if (params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    if params[:tag_type] == "crowd"
      @occurrences = Occurrence.includes(:event => :tags).where(:id => @occurrence_ids).sort{|a,b| ((b.clicks/b.views)*b.weight*b.venue.weight rescue 0) <=> ((a.clicks/a.views)*a.weight*a.venue.weight rescue 0) }
    end
   if params[:tag_type] == "staff"
     @occurrences = BookmarkList.find(2370).all_bookmarked_events.select{|k| @occurrence_ids.include?(k.id)}
   end
   if params[:tag_type] == "today" or params[:tag_type] == "tomorrow" or params[:tag_type] == "weekend"
     @occurrences = Occurrence.includes(:event => :tags).where(:id => @occurrence_ids).sort{|a,b| ((b.clicks/b.views)*b.weight*b.venue.weight rescue 0) <=> ((a.clicks/a.views)*a.weight*a.venue.weight rescue 0) }
   end
   if params[:tag_type] == "all"
     @occurrences = Occurrence.includes(:event => :tags).where(:id => @occurrence_ids)
   end
    params[:root]? @occurrences = @occurrences.take(5) : @occurrences = @occurrences
   p "params:"
    p params
    if params[:query].present?
        @occurrences = Occurrence.search_on_date(params).results#.select{ |o| (o.start >= (DateTime.parse("#{params[:start_date]}") rescue Date.today() )) and (o.start <= (DateTime.parse("#{params[:end_date]}") rescue Date.today()))  }.sort_by { |o| o.start }
    end
    if params[:filter_type] == "neighborhood" and params[:neighborhood_id].present?
      neighborhood = Neighborhood.find params[:neighborhood_id]
      @occurrences = neighborhood.occurrences.select{|k| @occurrences.map(&:id).include?(k.id)}#.page(1).per_page(21)
    end
    p "occurrences after fitering"
    p @occurrences
    @allOccurrences = @occurrences.select{ |o| o.start > Time.now }.uniq{|o| o.event_id}
    if params[:cost_sort] == "cost"
    @occurrences = @allOccurrences.sort_by { |o| params[:order_cost].to_i*o.event.price.to_f }.paginate(:page => params[:page], :per_page => 21)
    elsif params[:time_sort] == "time"
      if params[:order_time] == "1"
      @occurrences = @allOccurrences.sort_by{|o| o.start}.paginate(:page => params[:page], :per_page => 21)
      elsif params[:order_time] == "-1"
        @occurrences = @allOccurrences.sort_by{|o| o.start}.reverse!
        @occurrences = @occurrences.paginate(:page => params[:page], :per_page => 21)
      end
    else
      @occurrences = @allOccurrences.paginate(:page => params[:page], :per_page => 21)
    end
  end
  def neighbourhood_fetch
    @occurrences.each do |occurrence|
      break if @venue_neighbourhood.count == 100
      v = occurrence.venue
      if v.neighborhoods.empty?
        @venue_neighbourhood.count +=1
        @venue_neighbourhood.save
        fetch_neighborhoods(v.latitude,v.longitude,v.id)
      end

    end
  end
  def bookmark_popup
    #raise params.inspect
    @occurrence = Occurrence.find(params[:id])
    @event = @occurrence.event
    @bookmarks = []
    if (current_user)
      @bookmarks = Bookmark.where(:bookmarked_type => 'Occurrence', :bookmarked_id => @occurrence.id, :bookmark_list_id => current_user.bookmark_lists.collect(&:id))
      @bookmark_lists_ids = @bookmarks.empty? ? [0] : @bookmarks.collect(&:bookmark_list_id)
    end

  end

  def venue_bookmark_popup
    @venue = Venue.find(params[:id])
    @bookmarks = []
    if (current_user)
      @bookmarks = Bookmark.where(:bookmarked_type => 'Venue', :bookmarked_id => @venue.id, :bookmark_list_id => current_user.bookmark_lists.collect(&:id))
      @bookmark_lists_ids = @bookmarks.empty? ? [0] : @bookmarks.collect(&:bookmark_list_id)
    end
  end


  private

  def fetch_neighborhoods(lat,long,venue_id)
    client = Yelp::Client.new
    request = GeoPoint.new(
      :latitude => lat,
      :longitude => long)
    response = client.search(request)
    results = response['businesses']
    begin
      result = results.first
      nh_name = result['neighborhoods'].first['name']
      @neighborhood = Neighborhood.find_by_name_and_n_id(nh_name,result['id'])
      unless @neighborhood
        nh_options = {
          name: nh_name,
          n_id: result['id'],
          city: result['city'],
          state:  result['state'],
          state_code: result['state_code'],
          country: result['country'],
          country_code: result['country_code'],
          url: result['url']
        }
        @neighborhood = Neighborhood.new(nh_options)
        @neighborhood.save()
        puts "neighborhood: #{nh_name} done!"
      end
      venue = Venue.find(venue_id)
      venue.neighborhoods << @neighborhood
      venue.save()
    rescue Exception => e
      Rails.logger.info "error: #{e}"
      Rails.logger.info "result-neighborhoods: #{result['neighborhoods']}"
    end

    neighborhoods = []
    result.each do|result|
      neighborhoods << result['neighborhoods'].first.name rescue next
    end
  end
end
