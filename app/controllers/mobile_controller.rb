class MobileController < ApplicationController
  def og 
    @occurrence = Occurrence.find(params[:id])
    @event = @occurrence.event
    @pageTitle = @event.title + " | half past now."
    @description = strip_tags(@event.description)

    @eventid = Occurrence.find(params[:id]).event_id
    @event = Event.find(@eventid);

    @urlimage =@event.cover_image_url
    @url= 'http://www.halfpastnow.com/events/show/'+params[:id]+'?fullmode=true'
    render :layout => "og"
  end
  # def tp
  #   @list = BookmarkList.find(params[:id])
  #   @urlimage = @list.picture
  #   @url= 'http://secret-citadel-5147.herokuapp.com/mobile/tp/'+params[:id]
  #   render :layout => "tp"
  # end
  def new
    email = params[:email]
    password = params[:password]
    user = params[:username]
    lastname = params[:lastname]
    firstname = params[:firstname]
    if email.nil? or password.nil?

        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"0" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
        return
      end

    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user = nil  
    end
    if not @user.nil?
        #puts "Existing email"
          respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"1" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end

        return
    end
    @user = User.new()
    @user.email=email
    @user.password=password
    @user.username=user
    @user.lastname=lastname
    @user.firstname=firstname
    @user.save!
    respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"7" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
    end
  end

  def checkUser
    email = params[:email]
    password = params[:password]
    
     
    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user = nil
      
    end
    if @user.nil?
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"0" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
        return
      else
        if @user.valid_password?(params[:password])
          if @user.name.nil?
            @user.name =""
          end
          respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"1",user:@user } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
          end
          return
        else
         respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"2" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
          end
          return
        end
    end

  end


  def getBookmarkAndroid
    email = params[:email]
    password = params[:password]
    @bmEvents = []
    tmp ="0"
     
    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user=nil
      
    end
    if @user.nil?
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"0" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
        return
      else
        
         
           @channels= Channel.where("user_id=?",@user.id)
           query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url, events.ticket_url AS tix,occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix,occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

           queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :occurrence_id => s["occurrence_id"], #4
                
              }.values
              

              @bmEvents << item
            }
            # #puts esinfo.to_json

            @channels=[]
           @acts =  @user.bookmarked_acts.collect{|c|

            {
            :id=> c.id
            }.values


           }
           @venues = @user.bookmarked_venues.collect{|c| 
            {
            :id=> c.id
            }.values
          }
        
         



          respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"1",:bookmarked=>@bmEvents, :acts=>@acts, :venues=>@venues } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
          end
          return
        
    end
  end
  def checkUserAndroid
    email = params[:email]
    password = params[:password]
    @bmEvents = []
    tmp ="0"
      
    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user=nil
      
    end
    if @user.nil?
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"0" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
        return
      else
        if @user.valid_password?(params[:password])
         
           @channels= Channel.where("user_id=?",@user.id)
           query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url, events.ticket_url AS tix,occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix,occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

           
           queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
              e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              } 
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"],
                :url => s["url"]
              }.values
              

              @bmEvents << item
            }
            # #puts esinfo.to_json

            @channels =  @channels.collect{|s| 
            {

            :end_date=> s.end_date,
            :id=> s.id,
            :start_date=> s.start_date,
            :end_days=> s.end_days,
            :end_seconds=> s.end_seconds,
            :excluded_tags=> s.excluded_tags,
            :high_price=> s.high_price,
            :user_id=> s.user_id,
            :included_tags=> s.included_tags,
            :low_price=> s.low_price,
            :name=> s.name,
            :option_day=> s.option_day,
            :start_days=> s.start_days,
            :start_seconds=> s.start_seconds
            }.values

           }
           @acts =  @user.bookmarked_acts.collect{|c|

            {
            :id=> c.id,
            :name=> c.name,
            }.values


           }
           @venues = @user.bookmarked_venues.collect{|c| 
            {
            :name=> c.name,
            :id=> c.id,
            :address => c.address,
            :city=> c.city ,
            :zip=> c.zip,
            :latitude=> c.latitude,
            :longitude=> c.longitude
            }.values
          }
        
         



          respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"1",user:@user, channels: [],:bookmarked=>@bmEvents, :acts=>@acts, :venues=>@venues } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
          end
          return
        else
         respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"2" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
          end
          return
        end
    end

  end

  def checkFB
    email = params[:email]
    @user=User.find_by_email(email)
    if not @user.nil?
        respond_to do |format|
        format.html # index.html.erb
        format.json { render json: {:code=>"1" } }
          # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
        return
      else
        # Create user for FB
        @user = User.new()
        @user.email = params[:email]
        @user.lastname = params[:lastname]
        @user.firstname = params[:firstname]
        @user.password =  Devise.friendly_token[0,20]
        # @user.save!
        @user.uid = params[:uid]
        @user.fb_picture = params[:fb_picture]
        @user.profilepic = params[:fb_picture]
        @user.username = params[:username]
        
        @user.provider = "facebook"
        @user.save!
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"7" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
    end
    

  end


  # http://halfpastnow.herokuapp.com/mobile/myevents?format=json&collection_type=venue&collection=47065,39419,41428
  # http://halfpastnow.herokuapp.com/mobile/myevents?format=json&collection_type=act&collection=105,263,10028


  def myevents
    query = ""
    tmp ="0"
    if(params[:collection_type] == "venue")
      where_clause = "venues.id IN (#{params[:collection]})"
      query = "SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url, events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
          FROM occurrences 
            INNER JOIN events ON occurrences.event_id = events.id
            INNER JOIN venues ON events.venue_id = venues.id
            LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
            LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
            LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
            INNER JOIN recurrences ON events.id = recurrences.event_id
            LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
          WHERE #{where_clause} AND occurrences.recurrence_id IS NOT NULL AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS NOT TRUE
          UNION
          SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url, events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
          FROM occurrences 
            INNER JOIN events ON occurrences.event_id = events.id
            LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
            LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
            INNER JOIN venues ON events.venue_id = venues.id
            LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
            LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
          WHERE #{where_clause} AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS NOT TRUE"
            # ORDER BY events.id, occurrences.start"
    elsif(params[:collection_type] == "act")
      where_clause = "acts.id IN (#{params[:collection]})"
      query = "SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url, events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
          FROM occurrences 
            INNER JOIN events ON occurrences.event_id = events.id
            INNER JOIN venues ON events.venue_id = venues.id
            LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
            LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
            LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
            INNER JOIN recurrences ON events.id = recurrences.event_id
            LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
          WHERE #{where_clause} AND occurrences.recurrence_id IS NOT NULL AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS NOT TRUE
          UNION
          SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url, events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
          FROM occurrences 
            INNER JOIN events ON occurrences.event_id = events.id
            LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
            LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
            INNER JOIN venues ON events.venue_id = venues.id
            LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
            LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
          WHERE #{where_clause} AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS NOT TRUE"
    end
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end 
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    esinfo = []
    @eventIDs.each{ |id|
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      } 
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      s = set.first
      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"], # 24
                :url => s["url"] #25
              }





      esinfo << item
    }

   
    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.collect{|es| es.values}

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: {:events=>esinfo} }
    end
  end
  
  # deprecated method
  def FacebookLogin2
    #puts params[:email]
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 20
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end


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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    tmp ="0"
    tmp1 ="o"
    
    query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) #{tmp} AS listid,#{tmp} AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL
            UNION
            SELECT DISTINCT ON (events.id,acts.id) #{tmp} AS listid, #{tmp} AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
    
    
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    # #puts "queryResult------------------------"
    # #puts queryResult.to_json
    @ids = queryResult
    # #puts queryResult.uniq
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
      tpids = set.collect { |e|  e["listid"].to_i}.uniq
      tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps #23
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }

    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.drop(@offset).take(@amount)
    esinfo = esinfo.collect{|es| es.values}
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end

    # #puts esinfo.to_json
    #  Bookmarked events
    email = params[:email]
    @user=User.find_by_email(email)
    @bmEvents = []
    
    if not @user.nil?
      @channels= Channel.where("user_id=?",@user.id)
      query= "SELECT DISTINCT ON (recurrences.id,events.id) occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL
            UNION
            SELECT DISTINCT ON (events.id,events.id) occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL
            "

           queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs
            
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
              e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              } 
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [] #23
              }.values
              # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
              # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
              #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
              # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

              @bmEvents << item
            }
            # #puts esinfo.to_json

            @channels =  @channels.collect{|s| 
          {

          :end_date=> s.end_date,
          :id=> s.id,
          :start_date=> s.start_date,
          :end_days=> s.end_days,
          :end_seconds=> s.end_seconds,
          :excluded_tags=> s.excluded_tags,
          :high_price=> s.high_price,
          :user_id=> s.user_id,
          :included_tags=> s.included_tags,
          :low_price=> s.low_price,
          :name=> s.name,
          :option_day=> s.option_day,
          :start_days=> s.start_days,
          :start_seconds=> s.start_seconds
          }.values

         }
         @acts =  @user.bookmarked_acts.collect{|c|

          {
          :id=> c.id,
          :name=> c.name,
          }.values


         }
         @venues = @user.bookmarked_venues.collect{|c| 
          {
          :name=> c.name,
          :id=> c.id,
          :address => c.address,
          :city=> c.city ,
          :zip=> c.zip,
          :latitude=> c.latitude,
          :longitude=> c.longitude
          }.values


         }

    end

     
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>esinfo} }
      else
        
         format.json { render json: {user:@user, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten  } }
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
  end

def getbookmarks

end


def FacebookLoginAndroid
    #puts params[:email]
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    tpmatch =search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 20
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end

    # search
    unless(params[:tp].to_s.empty?)
      tpmatch = "bookmark_lists.featured IS TRUE"
    end
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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    # For next 5 hours
    if(!params[:next5].to_s.empty?)
      # now = Time.now
      event_start_date = Time.now #DateTime.new(now.year, now.month, now.day, now.hour, 0, 0, 0)
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:next5].to_s.empty?)
      event_end_date = Time.now.advance(:hours => 5)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end

    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:endf_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    tmp ="0"
    tmp1 ="o"
    
    query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start 
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE  #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
    
    
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    #puts "queryResult 10 "
    occurrenceIDs =  queryResult.collect { |e| e["occurrence_id"].to_i }.uniq
    ttttmp = queryResult.sort_by{ |hsh| hsh["start"].to_datetime }
    esinfo = ttttmp.drop(@offset).take(@amount)
    
    ids =  esinfo.collect { |e| e["occurrence_id"].to_i }.uniq.join(',')
    # #puts "iDs"
    # #puts ids
    esinfo = []
    if (ids.size > 0) && !ids.empty?
      query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix,bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid,#{tmp} AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid, #{tmp} AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})"
    
    # #puts "Query"
    # #puts query
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end

    # #puts "queryResult------------------------"
    # #puts queryResult.to_json
    @ids = queryResult
    # #puts queryResult.uniq
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      } 
      users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
      tpids = set.collect { |e|  e["listid"].to_i}.uniq
      # This could be cached
      tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      if tps.count == 0
        e = Event.find(id)
        if !e.nil?
          ids=e.bookmarks.collect{|b| b.bookmark_list_id}
          tps = BookmarkList.where(:id=>ids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
        end
        
      end
      
      
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps, #23
                :tix => s["tix"],
                :url => s["url"]
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }
    # #puts "Output: - before sorting "
    # #puts esinfo.to_json
    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    
    esinfo = ttttmp.collect{|es| es.values}
    end

    
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end
    # #puts "Output: "
    # #puts esinfo.to_json
    #  Bookmarked events
    email = params[:email]
    @user=User.find_by_email(email)
    @bmEvents = []
    @followedLists=[]
    if not @user.nil?
      @channels= Channel.where("user_id=?",@user.id)
      query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url, events.ticket_url AS tix,occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix,occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

         
           # #puts queryResult
           queryResult = ActiveRecord::Base.connection.select_all(query)
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
               e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              }
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"],
                :url => s["url"]
              }.values
              # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
              # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
              #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
              # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

              @bmEvents << item
            }
            # #puts esinfo.to_json

            @channels =  @channels.collect{|s| 
          {

          :end_date=> s.end_date,
          :id=> s.id,
          :start_date=> s.start_date,
          :end_days=> s.end_days,
          :end_seconds=> s.end_seconds,
          :excluded_tags=> s.excluded_tags,
          :high_price=> s.high_price,
          :user_id=> s.user_id,
          :included_tags=> s.included_tags,
          :low_price=> s.low_price,
          :name=> s.name,
          :option_day=> s.option_day,
          :start_days=> s.start_days,
          :start_seconds=> s.start_seconds
          }.values

         }
         @acts =  @user.bookmarked_acts.collect{|c|

          {
          :id=> c.id,
          :name=> c.name,
          }.values


         }
         @venues = @user.bookmarked_venues.collect{|c| 
          {
          :name=> c.name,
          :id=> c.id,
          :address => c.address,
          :city=> c.city ,
          :zip=> c.zip,
          :latitude=> c.latitude,
          :longitude=> c.longitude
          }.values


         }
         @followedLists=@user.followedLists.collect { |list| list.id }.flatten
    else
        @user = User.new()
        @user.email = params[:email]
        @user.lastname = params[:lastname]
        @user.firstname = params[:firstname]
        @user.password =  Devise.friendly_token[0,20]
        @user.uid = params[:uid]
        pix = "https://graph.facebook.com/"+params[:uid].to_s+"/picture?type=square"
        @user.fb_picture = pix
        @user.profilepic = pix
        @user.username = params[:username]
        
        @user.provider = "facebook"
        @user.save! 
        @bmEvents=[]
        esinfo=[]
        @acts=[]
        @venues=[]
        @followedLists=[]
    end

     
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>esinfo} }
      else
        
         format.json { render json: {code:"9", user:@user, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=> @followedLists } }
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
  end



# http://halfpastnow.herokuapp.com/mobile/FacebookLogin?format=json&sort=1&offset=0&amount=10&day=0,1,2,3,4,5,6&start_days=0&end_days=0&start_seconds=0&end_seconds=86399&low_price=&high_price=
def FacebookLogin
    #puts params[:email]
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    tpmatch =search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end

    # search
    unless(params[:tp].to_s.empty?)
      tpmatch = "bookmark_lists.featured IS TRUE"
    end
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
    end_date_check = distance_check=start_time_check = end_time_check = day_check = "TRUE"
    occurrence_start_time = "((EXTRACT(HOUR FROM occurrences.start) * 3600) + (EXTRACT(MINUTE FROM occurrences.start) * 60))"

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    # For next 5 hours
    if(!params[:next5].to_s.empty?)
      event_start_date = Time.now
      # now = Time.now
      # event_start_date = DateTime.new(now.year, now.month, now.day, now.hour, 0, 0, 0)
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:next5].to_s.empty?)
      now = Time.now
      event_end_date = now.advance(:hours => 5) #DateTime.new(now.year, now.month, now.day, now.hour+5, 0, 0, 0)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end

    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:endf_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"

    longitude = -97.742913
    latitude = 30.268021
    unless (params[:longitude].to_s.empty?)
      longitude = params[:longitude]
      latitude = params[:latitude] 
    end
    
    # Check distance
    if (!params[:distance].to_s.empty?)
      d = params[:distance]
      unless d.to_i == 77777
        distance_check ="ACOS( SIN(0.0174532925*#{latitude})*SIN(0.0174532925*venues.latitude) +COS(0.0174532925*#{latitude})*COS(0.0174532925*venues.latitude)*COS(0.0174532925*#{longitude}-0.0174532925*venues.longitude)  )<= #{d}"
      end 
    end

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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    elsif ( params[:sort].to_i == 1)
       order_by = "occurrences.start"
    elsif (params[:sort].to_i == 2) # Distance
       order_by = "ACOS( SIN(0.0174532925*#{latitude})*SIN(0.0174532925*venues.latitude) +COS(0.0174532925*#{latitude})*COS(0.0174532925*venues.latitude)*COS(0.0174532925*#{longitude}-0.0174532925*venues.longitude)  )"
    elsif (params[:sort].to_i == 3)
         order_by = "events.price"
                   
    end
    tmp ="0"
    tmp1 ="o"

    # order_by = "occurrences.start"
    puts "order_by"
    puts order_by
    
    query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start, venues.latitude AS latitude, venues.longitude AS longitude
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}' 
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start, venues.latitude AS latitude, venues.longitude AS longitude
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE  #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start, venues.latitude AS latitude, venues.longitude AS longitude
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}' 
            UNION
            SELECT DISTINCT ON (events.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start, venues.latitude AS latitude, venues.longitude AS longitude
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
           "
    
     # query = "SELECT occurrences.id AS occurrence_id, occurrences.start AS start
     #        FROM occurrences 
     #          INNER JOIN events ON occurrences.event_id = events.id
     #          LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
     #          LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
     #          INNER JOIN venues ON events.venue_id = venues.id
     #          LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
     #          LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
     #        WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
     #       ORDER BY #{order_by}"
   
    




    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}_#{distance_check}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)

      if (!params[:distance].to_s.empty?)
      d = params[:distance]
      unless d.to_i == 77777
        # distance_check ="ACOS( SIN(0.0174532925*#{latitude})*SIN(0.0174532925*venues.latitude) +COS(0.0174532925*#{latitude})*COS(0.0174532925*venues.latitude)*COS(0.0174532925*#{longitude}-0.0174532925*venues.longitude)  )<= #{d}"
        temp_result =[]
        latitude = latitude.to_f*0.0174532925
        longitude = longitude.to_f*0.0174532925
       

        queryResult.each{ |r|
          venue_lat = r["latitude"].to_f*0.0174532925
          venue_log = r["longitude"].to_f*0.0174532925
          if Math.acos( Math.sin(latitude)*Math.sin(venue_lat) +Math.cos(latitude)*Math.cos(venue_lat)*Math.cos(longitude-venue_log)  )<= d.to_f
            temp_result << r
          end
        }
        queryResult = temp_result


      end 
    end



      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    #puts "queryResult 10 "
    occurrenceIDs =  queryResult.collect { |e| e["occurrence_id"].to_i }.uniq
    # ttttmp = queryResult.sort_by{ |hsh| hsh["start"].to_datetime }
    @allOccurrences = Occurrence.includes(:event => :venue).find(occurrenceIDs, :order => order_by)
    # esinfo = queryResult.drop(@offset).take(@amount)
    esinfo = @allOccurrences.drop(@offset).take(@amount)
    # ids =  esinfo.collect { |e| e["occurrence_id"].to_i }.uniq.join(',')
    ids =  esinfo.collect { |e| e.id.to_i }.join(',')
    # #puts "iDs"
    # #puts ids
    esinfo = []
    if (ids.size > 0) && !ids.empty?
      query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix,bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid,#{tmp} AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid, #{tmp} AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})"
    
    # #puts "Query"
    # #puts query
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end

    # #puts "queryResult------------------------"
    # #puts queryResult.to_json
    @ids = queryResult
    # #puts queryResult.uniq
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }



      usersid = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      really_long_cache_name = Digest::SHA1.hexdigest("search_for_user_#{usersid}")
      users = Rails.cache.read(really_long_cache_name)
      if (users == nil)
        #puts "**************** No cache found for search query - user ids ****************"
        users = User.find(usersid).collect{|s| s.uid.to_s}.uniq
        Rails.cache.write(really_long_cache_name, users)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - user ids !!! ****************"
      end
      
      tpids = set.collect { |e|  e["listid"].to_i}.uniq
      tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      if tps.count == 0
        e = Event.find(id)
        if !e.nil?
          ids=e.bookmarks.collect{|b| b.bookmark_list_id}
          tps = BookmarkList.where(:id=>ids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
        end
        
      end
      
      
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
     
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end

      # #puts tags
     
      s = set.first
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps, #23
                :tix => s["tix"],
                :url => s["url"]
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }
    # #puts "Output: - before sorting "
    # #puts esinfo.to_json
    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    
    esinfo = ttttmp.collect{|es| es.values}
    end

    
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end
    # #puts "Output: "
    # #puts esinfo.to_json
    #  Bookmarked events
    email = params[:email]
    @user=User.find_by_email(email)
    @bmEvents = []
    @followedLists=[]
    if not @user.nil?
      @channels= Channel.where("user_id=?",@user.id)
      query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url, events.ticket_url AS tix,occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix,occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

          queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
              e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              }
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"],
                :url => s["url"]
              }.values
              # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
              # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
              #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
              # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

              @bmEvents << item
            }
            # #puts esinfo.to_json

            @channels =  @channels.collect{|s| 
          {

          :end_date=> s.end_date,
          :id=> s.id,
          :start_date=> s.start_date,
          :end_days=> s.end_days,
          :end_seconds=> s.end_seconds,
          :excluded_tags=> s.excluded_tags,
          :high_price=> s.high_price,
          :user_id=> s.user_id,
          :included_tags=> s.included_tags,
          :low_price=> s.low_price,
          :name=> s.name,
          :option_day=> s.option_day,
          :start_days=> s.start_days,
          :start_seconds=> s.start_seconds
          }.values

         }
         @acts =  @user.bookmarked_acts.collect{|c|

          {
          :id=> c.id,
          :name=> c.name,
          }.values


         }
         @venues = @user.bookmarked_venues.collect{|c| 
          {
          :name=> c.name,
          :id=> c.id,
          :address => c.address,
          :city=> c.city ,
          :zip=> c.zip,
          :latitude=> c.latitude,
          :longitude=> c.longitude
          }.values


         }
          # @followedLists=@user.followedLists.collect { |list| list.id }.flatten
   

    end

     
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>esinfo} }
      else
        
         format.json { render json: {code:"9", user:@user, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=>  @user.followedLists.collect { |list| list.id }.flatten} }
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
  end



# def FBlogin
#     #puts params[:email]
#     unless(params[:channel_id].to_s.empty?)
#       channel = Channel.find(params[:channel_id].to_i)

#       params[:option_day] ||= channel.option_day || 0
#       params[:start_days] ||= channel.start_days || ""
#       params[:end_days] ||= channel.end_days || ""
#       params[:start_seconds] ||= channel.start_seconds || ""
#       params[:end_seconds] ||= channel.end_seconds || ""
#       params[:low_price] ||= channel.low_price || ""
#       params[:high_price] ||= channel.high_price || ""
#       params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
#       params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
#       params[:lat_min] ||= ""
#       params[:lat_max] ||= ""
#       params[:long_min] ||= ""
#       params[:long_max] ||= ""
#       params[:offset] ||= 0
#       params[:search] ||= ""
#       params[:sort] ||= channel.sort || 0
#       params[:name] ||= channel.name || ""
#     end

#     if(params[:included_tags] && params[:included_tags].is_a?(String))
#       params[:included_tags] = params[:included_tags].split(",")
#     end
    
#     if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
#       params[:excluded_tags] = params[:excluded_tags].split(",")
#     end
#     # pp params
#     # @amount = params[:amount] || 20
#     # @offset = params[:offset] || 0

#     @tags = Tag.includes(:parentTag, :childTags).all
#     @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
#     tpmatch =search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
#     bookmarked = !params[:bookmark_type].to_s.empty?
#     # amount/offset
#     @amount = 20
#     unless(params[:amount].to_s.empty?)
#       @amount = params[:amount].to_i
#     end

#     @offset = 0
#     unless(params[:offset].to_s.empty?)
#       @offset = params[:offset].to_i
#     end

#     # search
#     unless(params[:tp].to_s.empty?)
#       tpmatch = "bookmark_lists.featured IS TRUE"
#     end
#     # search
#     unless(params[:search].to_s.empty?)
#       search = params[:search].gsub(/[^0-9a-z ]/i, '').upcase
#       searches = search.split(' ')
      
#       search_match_arr = []
#       searches.each do |word|
#         search_match_arr.push("(upper(venues.name) LIKE '%#{word}%' OR upper(events.description) LIKE '%#{word}%' OR upper(events.title) LIKE '%#{word}%')")
#       end

#       search_match = search_match_arr * " AND "
#     end


#     # date/time
#     start_date_check = "occurrences.start >= '#{Date.today()}'"
#     end_date_check = start_time_check = end_time_check = day_check = "TRUE"
#     occurrence_start_time = "((EXTRACT(HOUR FROM occurrences.start) * 3600) + (EXTRACT(MINUTE FROM occurrences.start) * 60))"

#     event_start_date = event_end_date = nil
#     if(!params[:start_date].to_s.empty?)
#       event_start_date = Date.parse(params[:start_date])
#     else
#       event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
#     end
#     if(!params[:end_date].to_s.empty?)
#       event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
#     else
#       event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
#     end
    
#     start_date_check = "occurrences.start >= '#{event_start_date}'"
#     end_date_check = "occurrences.start <= '#{event_end_date}'"

#     unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
#       event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
#       event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

#       start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
#       end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
#     end

#     unless(params[:day].to_s.empty?)
#       # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
#       event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
#       days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
#     end

#     occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


#     # location
#     if(params[:lat_min].to_s.empty? || params[:long_min].to_s.empty? || params[:lat_max].to_s.empty? || params[:long_max].to_s.empty?)
#       @ZoomDelta = {
#                11 => { :lat => 0.30250564 / 2, :long => 0.20942688 / 2 }, 
#                13 => { :lat => 0.0756264644 / 2, :long => 0.05235672 / 2 }, 
#                14 => { :lat => 0.037808182 / 2, :long => 0.02617836 / 2 }
#               }

#       # 30.268093,-97.742808
#       @lat = 30.268093
#       @long = -97.742808
#       @zoom = 11

#       unless params[:location].to_s.empty?
#         json_object = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + URI::encode(params[:location])).read)
#         unless (json_object.nil? || json_object["results"].length == 0)

#           @lat = json_object["results"][0]["geometry"]["location"]["lat"]
#           @long = json_object["results"][0]["geometry"]["location"]["lng"]
#           # if the results are of a city, keep it zoomed out aways
#           if (json_object["results"][0]["address_components"][0]["types"].index("locality").nil?)
#             @zoom = 14
#           end
#         end
#       end

#       @lat_delta = @ZoomDelta[@zoom][:lat]
#       @long_delta = @ZoomDelta[@zoom][:long]
#       @lat_min = @lat - @lat_delta
#       @lat_max = @lat + @lat_delta
#       @long_min = @long - @long_delta
#       @long_max = @long + @long_delta
#     else
#       @lat_min = params[:lat_min]
#       @lat_max = params[:lat_max]
#       @long_min = params[:long_min]
#       @long_max = params[:long_max]
#     end

#     location_match = "venues.id = events.venue_id AND venues.latitude >= #{@lat_min} AND venues.latitude <= #{@lat_max} AND venues.longitude >= #{@long_min} AND venues.longitude <= #{@long_max}"

#     # tags
#     unless(params[:included_tags].to_s.empty?)
#       tags_mush = params[:included_tags] * ','

#       # tag_include_match = "events.id IN (
#       #               SELECT event_id 
#       #                 FROM events, tags, events_tags 
#       #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
#       #                 GROUP BY event_id 
#       #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
#       #             )"

#       tag_include_match = "tags.id IN (#{tags_mush})"
#     end

#     unless(params[:excluded_tags].to_s.empty?)
#       tags_mush = params[:excluded_tags] * ','
#       tag_exclude_match = "events.id NOT IN (
#                     SELECT event_id 
#                       FROM events, tags, events_tags 
#                       WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
#                       GROUP BY event_id
#                   )"
#     end

#     # price
#     unless(params[:low_price].to_s.empty?)
#       low_price = params[:low_price].to_i
#       low_price_match = "events.price >= #{low_price}"
#     end

#     unless(params[:high_price].to_s.empty?)
#       high_price = params[:high_price].to_i
#       high_price_match = "events.price <= #{high_price}"
#     end

#     order_by = "occurrences.start"
#     if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
#       # order by event score when sorting by popularity
#       order_by = "CASE events.views 
#                     WHEN 0 THEN 0
#                     ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
#                   END DESC"
#     end
#     tmp ="0"
#     tmp1 ="o"
    
#     query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start 
#             FROM users
#               INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
#               INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
#               INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
#               INNER JOIN events ON occurrences.event_id = events.id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN recurrences ON events.id = recurrences.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE  #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
#             UNION
#             SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start
#             FROM users
#               INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
#               INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
#               INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
#               INNER JOIN events ON occurrences.event_id = events.id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
#             UNION
#             SELECT DISTINCT ON (recurrences.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
#             FROM occurrences 
#               INNER JOIN events ON occurrences.event_id = events.id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN recurrences ON events.id = recurrences.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
#             UNION
#             SELECT DISTINCT ON (events.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
#             FROM occurrences 
#               INNER JOIN events ON occurrences.event_id = events.id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
    
    
#     queryResult = ActiveRecord::Base.connection.select_all(query)
#     #puts "queryResult 10 "
#     occurrenceIDs =  queryResult.collect { |e| e["occurrence_id"].to_i }.uniq
#     ttttmp = queryResult.sort_by{ |hsh| hsh["start"].to_datetime }
#     esinfo = ttttmp.drop(@offset).take(@amount)
    
#     ids =  esinfo.collect { |e| e["occurrence_id"].to_i }.uniq.join(',')
#     # #puts "iDs"
#     # #puts ids
#     esinfo = []
#     if (ids.size > 0) && !ids.empty?
#       query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
#             FROM users
#               INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
#               INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
#               INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
#               INNER JOIN events ON occurrences.event_id = events.id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN recurrences ON events.id = recurrences.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE occurrences.id IN (#{ids})
#             UNION
#             SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix,bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
#             FROM users
#               INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
#               INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
#               INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
#               INNER JOIN events ON occurrences.event_id = events.id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE occurrences.id IN (#{ids})
#             UNION
#             SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid,#{tmp} AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
#             FROM occurrences 
#               INNER JOIN events ON occurrences.event_id = events.id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN recurrences ON events.id = recurrences.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE occurrences.id IN (#{ids})
#             UNION
#             SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid, #{tmp} AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
#             FROM occurrences 
#               INNER JOIN events ON occurrences.event_id = events.id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#             WHERE occurrences.id IN (#{ids})"
    
#     # #puts "Query"
#     # #puts query
#     queryResult = ActiveRecord::Base.connection.select_all(query)

#     # #puts "queryResult------------------------"
#     # #puts queryResult.to_json
#     @ids = queryResult
#     # #puts queryResult.uniq
#     @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
#     # #puts @eventIDs
#     esinfo = []
#     @eventIDs.each{ |id|
#       # #puts id
#       # #puts "SET"
#       set =  queryResult.select{ |r| r["event_id"] == id.to_s }
#       # #puts set
#       act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
#       users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
#       users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
#       tpids = set.collect { |e|  e["listid"].to_i}.uniq
#       tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
#       if tps.count == 0
#         e = Event.find(id)
#         if !e.nil?
#           ids=e.bookmarks.collect{|b| b.bookmark_list_id}
#           tps = BookmarkList.where(:id=>ids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
#         end
        
#       end
      
      
#       # #puts tps
#       # act = set.collect { |s|  {s["actor"], s["act_id"]} }
#       # Find the uniq recurrence id
#       rec_ids = set.collect { |e| e["rec_id"] }.uniq
#       rec = set.collect { |s| { 
#         :every_other => s["every_other"],
#         :day_of_week => s["day_of_week"],
#         :week_of_month => s["week_of_month"], 
#         :day_of_month => s["day_of_month"] ,
#         :rec_start => s["rec_start"],  # 4
#         :rec_end => s["rec_end"]  # 5

#         }.values}.uniq 
#       # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
#       tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
#       # #puts tags
     
#       s = set.first
#       # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
#       # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
#       # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
#       # :views => s["views"], :tags  =>  tags }

#       item = {
#                 :act => act, # 0
#                 :rec => rec , # 1
#                 :description => s["description"], # 2
#                 :title => s["title"], # 3
#                 :occurrence_id => s["occurrence_id"], #4
#                 :cover => s["cover"] , #5
#                 :venue_name => s["venue_name"], #6
#                 :address => s["address"] , #7
#                 :zip => s["zip"] , #8
#                 :city => s["city"], #9
#                 :state => s["state"] , #10
#                 :phone => s["phone"], # 11
#                 :lat => s["latitude"], # 12
#                 :long => s["longitude"], #13
#                 :venue_id => s["venue_id"], # 14
#                 :price => s["price"] , #15
#                 :views => s["views"],  #16
#                 :clicks => s["clicks"], #17
#                 :tags  => tags , # 18
#                 :event_id => s["event_id"], #19
#                 :start => s["occurrence_start"] , #20
#                 :end => s["end"], #21
#                 :user => users, #22
#                 :tps =>  tps, #23
#                 :tix => s["tix"],
#                 :url => s["url"]
#               }


#       # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
#       # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
#       # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
#       # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



#       esinfo << item
#     }
#     # #puts "Output: - before sorting "
#     # #puts esinfo.to_json
#     ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    
#     esinfo = ttttmp.collect{|es| es.values}
#     end

    
#     @amount = 10
#     unless(params[:amount].to_s.empty?)
#       @amount = params[:amount].to_i
#     end

#     @offset = 0
#     unless(params[:offset].to_s.empty?)
#       @offset = params[:offset].to_i
#     end
#     # #puts "Output: "
#     # #puts esinfo.to_json
#     #  Bookmarked events
#     email = params[:email]
#     @user=User.find_by_email(email)
#     @bmEvents = []
    
#     if not @user.nil?
#       @channels= Channel.where("user_id=?",@user.id)
#       query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url, events.ticket_url AS tix,occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
#             FROM occurrences
#               INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
#               INNER JOIN events ON occurrences.event_id = events.id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               INNER JOIN recurrences ON events.id = recurrences.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
#               INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
#            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
#             UNION
#             SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix,occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
#             FROM occurrences
#               INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
#               INNER JOIN events ON occurrences.event_id = events.id
#               INNER JOIN venues ON events.venue_id = venues.id
#               LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
#               LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
#               LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
#               LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
#               INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
#             WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
#             "

#            queryResult = ActiveRecord::Base.connection.select_all(query)
#            # #puts queryResult
#            @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

#            # #puts @eventIDs#puts
            
#             @eventIDs.each{ |id|
#               # #puts id
#               # #puts "SET"
#               set =  queryResult.select{ |r| r["event_id"] == id.to_s }
#                act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
#                # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
#               # Find the uniq recurrence id
#               rec_ids = set.collect { |e| e["rec_id"] }.uniq
#                rec = set.collect { |s| { 
#                 :every_other => s["every_other"], # 0
#                 :day_of_week => s["day_of_week"], # 1
#                 :week_of_month => s["week_of_month"], # 2 
#                 :day_of_month => s["day_of_month"],  # 3
#                 :rec_start => s["rec_start"],  # 4
#                 :rec_end => s["rec_end"]  # 5
#                 }.values
#                 }.uniq 
#                 # #puts rec
#               # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
#               s = set.first
#               tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
#               item = {
#                 :act => act, # 0
#                 :rec => rec , # 1
#                 :description => s["description"], # 2
#                 :title => s["title"], # 3
#                 :occurrence_id => s["occurrence_id"], #4
#                 :cover => s["cover"] , #5
#                 :venue_name => s["venue_name"], #6
#                 :address => s["address"] , #7
#                 :zip => s["zip"] , #8
#                 :city => s["city"], #9
#                 :state => s["state"] , #10
#                 :phone => s["phone"], # 11
#                 :lat => s["latitude"], # 12
#                 :long => s["longitude"], #13
#                 :venue_id => s["venue_id"], # 14
#                 :price => s["price"] , #15
#                 :views => s["views"],  #16
#                 :clicks => s["clicks"], #17
#                 :tags  => tags , # 18
#                 :event_id => s["event_id"], #19
#                 :start => s["occurrence_start"] , #20
#                 :end => s["end"], #21,
#                 :user => [], #22
#                 :tps =>  [], #23
#                 :tix => s["tix"],
#                 :url => s["url"]
#               }.values
#               # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
#               # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
#               #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
#               # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

#               @bmEvents << item
#             }
#             # #puts esinfo.to_json

#          #    @channels =  @channels.collect{|s| 
#          #  {

#          #  :end_date=> s.end_date,
#          #  :id=> s.id,
#          #  :start_date=> s.start_date,
#          #  :end_days=> s.end_days,
#          #  :end_seconds=> s.end_seconds,
#          #  :excluded_tags=> s.excluded_tags,
#          #  :high_price=> s.high_price,
#          #  :user_id=> s.user_id,
#          #  :included_tags=> s.included_tags,
#          #  :low_price=> s.low_price,
#          #  :name=> s.name,
#          #  :option_day=> s.option_day,
#          #  :start_days=> s.start_days,
#          #  :start_seconds=> s.start_seconds
#          #  }.values

#          # }
#          @acts =  @user.bookmarked_acts.collect{|c|

#           {
#           :id=> c.id,
#           :name=> c.name,
#           }.values


#          }
#          @venues = @user.bookmarked_venues.collect{|c| 
#           {
#           :name=> c.name,
#           :id=> c.id,
#           :address => c.address,
#           :city=> c.city ,
#           :zip=> c.zip,
#           :latitude=> c.latitude,
#           :longitude=> c.longitude
#           }.values


#          }

#     end

#     @channels =[];
#     respond_to do |format|
#       format.html do
#         unless (params[:ajax].to_s.empty?)
#           render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
#         end
#       end

#       # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
#       if (params[:email].to_s.empty?)
#         # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
#         format.json { render json: {:events=>esinfo} }
#       else
        
#          # format.json { render json: {user:@user, channels: @channels,:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten  } }
#          format.json { render json: {user:@user, channels: @channels,:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten  } }
         
#          # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
#         # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
#       end

#     end
    
#   end

def homeEvents
  unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end


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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end

    # if(params[:channel_id].to_s.empty?)
    #   event_end_date = Date.today().advance(:days => 2)
    # else
    #   event_end_date = Date.today().advance(:days => 14)
    # end


    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    tmp ="0"
    tmp1 ="o"
    
    query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start 
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
    
    
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    #puts "queryResult 10 "
    order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    # order_by = "events.views"

    ttmp = queryResult.uniq{|x| x["occurrence_id"]}
    # ttttmp = ttmp.sort_by{ |hsh| hsh["occurrence_start"].to_datetime }
    # esinfo = tes.drop(@offset).take(@amount)
    #puts "offset"
    #puts @offset
    #puts "amount"
    #puts @amount
    size = ttmp.size
   

    if(params[:channel_id].to_s.empty?)
      ttttmp = queryResult.select{|e| e["start"].to_datetime > Time.now && e["start"].to_datetime < Date.today().advance(:days => 2)}
    elsif (params[:channel_id].to_i == 3579)
      ttttmp = queryResult.select{|e| e["start"].to_datetime > Time.now && e["start"].to_datetime < Date.today().advance(:days => 30)}
    elsif (params[:channel_id].to_i == 264)
      ttttmp = queryResult.select{|e| e["start"].to_datetime > Time.now && e["start"].to_datetime < Date.today().advance(:days => 365)}
    else
      ttttmp = queryResult.select{|e| e["start"].to_datetime > Time.now && e["start"].to_datetime < Date.today().advance(:days => 14)}
    end


    occurrenceIDs =  ttttmp.collect { |e| e["occurrence_id"].to_i }
    # ttttmp = queryResult.sort_by{ |hsh| hsh["start"].to_datetime }
    @allOccurrences = Occurrence.includes(:event => :venue).find(occurrenceIDs, :order => order_by)
    occurrenceIDs =  @allOccurrences.collect { |e| e.id.to_i }.take(5)
   
    # today_events = queryResult.select{|e| e["start"].to_datetime < Date.today().advance(:days => 1)}.take(2)
    # tomorrow_events = queryResult.select{|e| e["start"].to_datetime > Date.today().advance(:days => 1)}.take(2)
    # esinfo =[]
    # esinfo << today_events << tomorrow_events
    # esinfo=esinfo.flatten


    ids =  occurrenceIDs.join(',')
    # #puts "iDs"
    # #puts ids
    esinfo = []
    if (ids.size > 0) && !ids.empty?
      query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid,#{tmp} AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid, #{tmp} AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})"
    
    # #puts "Query"
    # #puts query
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end

    # #puts "queryResult------------------------"
    # #puts queryResult.to_json
    @ids = queryResult
    # #puts queryResult.uniq
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
      tpids = set.collect { |e|  e["listid"].to_i}.uniq
      tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      if tps.count == 0
        e = Event.find(id)
        if !e.nil?
          ids=e.bookmarks.collect{|b| b.bookmark_list_id}
          tps = BookmarkList.where(:id=>ids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
        end
        
      end
      
      
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps, #23
                :tix => s["tix"],
                :url => s["url"]
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }
    # #puts "Output: - before sorting "
    # #puts esinfo.to_json
    # ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    
    esinfo = esinfo.collect{|es| es.values}
    end

    
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end
    # #puts "Output: "
    # #puts esinfo.to_json
    #  Bookmarked events
    email = params[:email]
    @user=User.find_by_email(email)
    @bmEvents = []
    @followedList = []
    if not @user.nil?
       @followedList = @user.followedLists.collect { |list| list.id }.flatten  
      @channels= Channel.where("user_id=?",@user.id)
      query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

         
          queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
              e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              }
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"],
                :url => s["url"]
              }.values
              # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
              # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
              #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
              # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

              @bmEvents << item
            }


            #  Get RSVP Events
            query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.name ='Attending' AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.name ='Attending' AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

          queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            @RSVP =[]
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
              e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              }
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"],
                :url => s["url"]
              }.values
              # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
              # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
              #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
              # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

              @RSVP << item
            }




            # #puts esinfo.to_json

            @channels =  @channels.collect{|s| 
          {

          :end_date=> s.end_date,
          :id=> s.id,
          :start_date=> s.start_date,
          :end_days=> s.end_days,
          :end_seconds=> s.end_seconds,
          :excluded_tags=> s.excluded_tags,
          :high_price=> s.high_price,
          :user_id=> s.user_id,
          :included_tags=> s.included_tags,
          :low_price=> s.low_price,
          :name=> s.name,
          :option_day=> s.option_day,
          :start_days=> s.start_days,
          :start_seconds=> s.start_seconds
          }.values

         }
         @acts =  @user.bookmarked_acts.collect{|c|

          {
          :id=> c.id,
          :name=> c.name,
          }.values


         }
         @venues = @user.bookmarked_venues.collect{|c| 
          {
          :name=> c.name,
          :id=> c.id,
          :address => c.address,
          :city=> c.city ,
          :zip=> c.zip,
          :latitude=> c.latitude,
          :longitude=> c.longitude
          }.values


         }

    end


    # Choose 2 events for today and tomorrow
   
    # today_events = esinfo.select{|e| e[20].to_time < Date.today().advance(:days => 1)}.take(@amount)
    # tomorrow_events = esinfo.select{|e| e[20].to_time > Date.today().advance(:days => 1)}.take(@amount)
    first5 = esinfo
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:size => size,:first5=>first5,:events => esinfo} }
      else
        
         format.json { render json: {:size => size,:first5=>first5, user:@user, :RSVP =>@RSVP, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=> @followedList}}
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
  
  
end


def gethometpevents
    #puts params[:email]
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    tpmatch =search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end

    # search
    unless(params[:tp].to_s.empty?)
      tpmatch = "bookmark_lists.featured IS TRUE"
    end
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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    tmp ="0"
    tmp1 ="o"
    

    query = "SELECT DISTINCT ON (recurrences.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, bookmark_lists.picture AS pix, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE bookmark_lists.featured IS NOT FALSE AND #{search_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND #{days_check} AND occurrences.recurrence_id IS NOT NULL AND (recurrences.range_end >= '#{Date.today()}' OR recurrences.range_end IS NULL)
            UNION
            SELECT DISTINCT ON (events.id) events.event_url AS url,events.ticket_url AS tix,bookmark_lists.id AS listid, bookmark_lists.picture AS pix, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE bookmark_lists.featured IS NOT FALSE AND occurrences.start >= '#{Date.today()}' AND #{search_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{days_check} AND #{low_price_match} AND #{high_price_match}
            "

    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult==nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)   
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end

   
    occurrences =[]
    recurrenceids = queryResult.select{|r| r["recurrence_id"] != "0"}.collect { |e| e["recurrence_id"].to_i }.uniq
    queryResult.each{|r|
      if r["recurrence_id"] != "0"


        occ = Rails.cache.read("occurrence_find_#{r["event_id"].to_s}_event_nextOccurrence")
        if (occ==nil)
          #puts "Cache not found"
          occ = Event.find(r["event_id"].to_i).nextOccurrence
          Rails.cache.write("occurrence_find_#{r["event_id"].to_s}_event_nextOccurrence", occ)
        else
          #puts "Cache found"
        end
        
        unless occ.nil?
          r["occurrence"] = occ[:id]
          r["occurrence_start"]  = occ[:start].strftime("%F %T")
        end
        
       end
    }
    # #puts occurrences
    # ttttmp = queryResult.sort_by{ |hsh| hsh["occurrence_start"].to_datetime }
    es = queryResult.select{|r|
      r["occurrence_start"].to_datetime >= event_start_date && r["occurrence_start"].to_datetime <= event_end_date
    }
    tes =[]
    es.each{|r|
      t = Time.parse(r["occurrence_start"])
      s = t.hour * 60 * 60 + t.min * 60 + t.sec
      if (s>=event_start_time) && (s<=event_end_time)
        tes<<r
      end
    }
    ttmp = tes.uniq{|x| x["event_id"]}
    # ttttmp = ttmp.sort_by{ |hsh| hsh["occurrence_start"].to_datetime }
    # esinfo = tes.drop(@offset).take(@amount)
    #puts "offset"
    #puts @offset
    #puts "amount"
    #puts @amount
    size = ttmp.size
   
    ttttmp = ttmp.select{|e| e["occurrence_start"].to_datetime > Time.now && e["occurrence_start"].to_datetime < Date.today().advance(:days => 14)}
    @eventIDs =  ttttmp.collect { |e| e["event_id"] }.uniq.take(5)
   






    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
      # tpids = set.collect { |e|  e["listid"].to_i}.uniq
      # tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      # if tps.count == 0
      #   e = Event.find(id)
      #   if !e.nil?
      #     ids=e.bookmarks.collect{|b| b.bookmark_list_id}
      #     tps = BookmarkList.where(:id=>ids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      #   end
        
      # end
      tps=[]
      tpids = set.collect { |e|  {:id => e["listid"].to_i, :pix => e["pix"]}}.uniq
      tpids.each{|tpid|
        tps << "http://hpn-pictures.s3.amazonaws.com/uploads/bookmark_list/picture/"+tpid[:id].to_s+"/mini_"+tpid[:pix]
      }
      
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      
      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps, #23
                :tix => s["tix"],
                :url => s["url"]
              }
     esinfo << item
    }

    # today_events = esinfo.select{|e| e[:start].to_time > Time.now && e[:start].to_time < Date.today().advance(:days => 1)}.take(@amount).collect{|es| es.values}
    # tomorrow_events = esinfo.select{|e| e[:start].to_time > Date.today().advance(:days => 1)}.take(@amount).collect{|es| es.values}
    first5 = esinfo.collect{|es| es.values}
    
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:size=>size,:first5=>first5} }
      else
        
         format.json { render json: {:size=>size,:first5=>first5,user:@user, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten  } }
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
end


def gettpevents
    #puts params[:email]
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    tpmatch =search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 20
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end

    # search
    unless(params[:tp].to_s.empty?)
      tpmatch = "bookmark_lists.featured IS TRUE"
    end
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
    end_date_check = distance_check = start_time_check = end_time_check = day_check = "TRUE"
    occurrence_start_time = "((EXTRACT(HOUR FROM occurrences.start) * 3600) + (EXTRACT(MINUTE FROM occurrences.start) * 60))"

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"

    longitude = -97.742913
    latitude = 30.268021
    unless (params[:longitude].to_s.empty?)
      longitude = params[:longitude].to_f
      latitude = params[:latitude] .to_f
    end
    
    # Check distance
    if (!params[:distance].to_s.empty?)
      d = params[:distance]
      unless d.to_i == 77777
        distance_check ="ACOS( SIN(0.0174532925*#{latitude})*SIN(0.0174532925*venues.latitude) +COS(0.0174532925*#{latitude})*COS(0.0174532925*venues.latitude)*COS(0.0174532925*#{longitude}-0.0174532925*venues.longitude)  )<= #{d}"
      end 
    end

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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    

    tmp ="0"
    tmp1 ="o"
    

    query = "SELECT DISTINCT ON (recurrences.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, bookmark_lists.picture AS pix, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start, venues.longitude AS longitude, venues.latitude AS latitude
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE bookmark_lists.featured IS NOT FALSE AND #{search_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND #{days_check} AND occurrences.recurrence_id IS NOT NULL AND (recurrences.range_end >= '#{Date.today()}' OR recurrences.range_end IS NULL)
            UNION
            SELECT DISTINCT ON (events.id) events.event_url AS url,events.ticket_url AS tix,bookmark_lists.id AS listid, bookmark_lists.picture AS pix, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start, venues.longitude AS longitude, venues.latitude AS latitude
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE bookmark_lists.featured IS NOT FALSE AND occurrences.start >= '#{Date.today()}' AND #{search_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{days_check} AND #{low_price_match} AND #{high_price_match}
            "

    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}_#{distance_check}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult==nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)


      if (!params[:distance].to_s.empty?)
        d = params[:distance]
        unless d.to_i == 77777
          # distance_check ="ACOS( SIN(0.0174532925*#{latitude})*SIN(0.0174532925*venues.latitude) +COS(0.0174532925*#{latitude})*COS(0.0174532925*venues.latitude)*COS(0.0174532925*#{longitude}-0.0174532925*venues.longitude)  )<= #{d}"
          temp_result =[]
          latitude1 = latitude.to_f*0.0174532925
          longitude1 = longitude.to_f*0.0174532925
         

          queryResult.each{ |r|
            venue_lat = r["latitude"].to_f*0.0174532925
            venue_log = r["longitude"].to_f*0.0174532925
            if Math.acos( Math.sin(latitude1)*Math.sin(venue_lat) +Math.cos(latitude1)*Math.cos(venue_lat)*Math.cos(longitude1-venue_log)  )<= d.to_f
              temp_result << r
            end
          }
          queryResult = temp_result


        end 
      end



      Rails.cache.write(really_long_cache_name, queryResult)   
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end

   
    occurrences =[]
    recurrenceids = queryResult.select{|r| r["recurrence_id"] != "0"}.collect { |e| e["recurrence_id"].to_i }.uniq
    queryResult.each{|r|
      if r["recurrence_id"] != "0"


        occ = Rails.cache.read("occurrence_find_#{r["event_id"].to_s}_event_nextOccurrence")
        if (occ==nil)
          #puts "Cache not found"
          occ = Event.find(r["event_id"].to_i).nextOccurrence
          Rails.cache.write("occurrence_find_#{r["event_id"].to_s}_event_nextOccurrence", occ)
        else
          #puts "Cache found"
        end
        
        unless occ.nil?
          r["occurrence"] = occ[:id]
          r["occurrence_start"]  = occ[:start].strftime("%F %T")
        end
        
       end
    }
    # #puts occurrences
    # ttttmp = queryResult.sort_by{ |hsh| hsh["occurrence_start"].to_datetime }
    es = queryResult.select{|r|
      r["occurrence_start"].to_datetime >= event_start_date && r["occurrence_start"].to_datetime <= event_end_date
    }
    tes =[]
    es.each{|r|
      t = Time.parse(r["occurrence_start"])
      s = t.hour * 60 * 60 + t.min * 60 + t.sec
      if (s>=event_start_time) && (s<=event_end_time)
        tes<<r
      end
    }
    ttmp = tes.uniq{|x| x["event_id"]}


   


    ttttmp = ttmp

    



    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      ttttmp = ttmp.sort{ |a,b| a["views"].to_i  <=> b["views"].to_i}
    elsif ( params[:sort].to_i == 1)
      ttttmp = ttmp.sort_by{ |hsh| hsh["occurrence_start"].to_datetime }
    elsif (params[:sort].to_i == 2) # Distance
      temp = []
      latitude1 = latitude.to_f*0.0174532925
      longitude1 = longitude.to_f*0.0174532925
      ttttmp.each{ |item|
        log = item["longitude"].to_f*0.0174532925
        lat = item["latitude"].to_f*0.0174532925
        d = Math.acos( Math.sin(latitude1)*Math.sin(lat) +Math.cos(latitude1)*Math.cos(lat)*Math.cos(longitude1-log))
        item=item.merge({"distance"=>d})
       
        temp << item
      }
      ttttmp = temp.sort_by{ |hsh| hsh["distance"]} 
    elsif (params[:sort].to_i == 3)

      temp = []
      ttttmp.each{ |item|
        p = 77777777777.0
        if ((!item["price"].to_s.empty?) && (!item["price"].nil?) && (!item["price"].to_s.eql?("")) &&( !item["price"].blank? ))
          p = item["price"].to_f 
        end
        item = item.merge({"p"=>p})
        
        temp << item

      }
      ttttmp = temp.sort_by{ |hsh| hsh["p"] }            
    end

    # if (!params[:distance].to_s.empty?)
    #   d = params[:distance]
    #   unless d.to_i == 77777
    #   temp = []
    #   ttttmp.each{ |item|
    #     log = item["longitude"].to_f*0.0174532925
    #     lat = item["latitude"].to_f*0.0174532925
    #     k = Math.acos( Math.sin(latitude*0.0174532925)*Math.sin(lat) +Math.cos(latitude*0.0174532925)*Math.cos(lat)*Math.cos(longitude*0.0174532925-log))
    #     item.merge({"cadistance"=>k})

    #     temp << item
    #   }
    #   ttttmp = temp.select{|item| item["cadistance"].to_f <= d.to_f}

    #   end 
    # end


    
    esinfo = ttttmp.drop(@offset).take(@amount)






    # esinfo = tes.drop(@offset).take(@amount)
    #puts "offset"
    #puts @offset
    #puts "amount"
    #puts @amount
    
    @eventIDs =  esinfo.collect { |e| e["event_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
      # tpids = set.collect { |e|  e["listid"].to_i}.uniq
      # tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      # if tps.count == 0
      #   e = Event.find(id)
      #   if !e.nil?
      #     ids=e.bookmarks.collect{|b| b.bookmark_list_id}
      #     tps = BookmarkList.where(:id=>ids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      #   end
        
      # end
      tps=[]
      tpids = set.collect { |e|  {:id => e["listid"].to_i, :pix => e["pix"]}}.uniq
      tpids.each{|tpid|
        tps << "http://hpn-pictures.s3.amazonaws.com/uploads/bookmark_list/picture/"+tpid[:id].to_s+"/mini_"+tpid[:pix]
      }
      
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      
      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps, #23
                :tix => s["tix"],
                :url => s["url"]
              }
     esinfo << item
    }
    # ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    
    esinfo = esinfo.collect{|es| es.values}
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>esinfo} }
      else
        
         format.json { render json: {user:@user, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten  } }
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
end
def FacebookLoginSX
    #puts params[:email]
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 20
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end


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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    tmp ="0"
    tmp1 ="o"
    
    query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start 
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL AND recurrences.end >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
    
    
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    #puts "queryResult 10 "
    occurrenceIDs =  queryResult.collect { |e| e["occurrence_id"].to_i }.uniq
    ttttmp = queryResult.sort_by{ |hsh| hsh["start"].to_datetime }
    esinfo = ttttmp.drop(@offset).take(@amount)
    
    ids =  esinfo.collect { |e| e["occurrence_id"].to_i }.uniq.join(',')
    # #puts "iDs"
    # #puts ids
    esinfo = []
    if (ids.size > 0) && !ids.empty?
      query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid,#{tmp} AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url,events.ticket_url AS tix, #{tmp} AS listid, #{tmp} AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})"
    
    # #puts "Query"
    # #puts query
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end

    # #puts "queryResult------------------------"
    # #puts queryResult.to_json
    @ids = queryResult
    # #puts queryResult.uniq
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
      tpids = set.collect { |e|  e["listid"].to_i}.uniq
      tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      if tps.count == 0
        e = Event.find(id)
        if !e.nil?
          ids=e.bookmarks.collect{|b| b.bookmark_list_id}
          tps = BookmarkList.where(:id=>ids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
        end
        
      end
      
      
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps, #23
                :tix => s["tix"],
                :url => s["url"]
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }
    # #puts "Output: - before sorting "
    # #puts esinfo.to_json
    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    
    esinfo = ttttmp.collect{|es| es.values}
    end

    
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end
    # #puts "Output: "
    # #puts esinfo.to_json
    #  Bookmarked events
    email = params[:email]
    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user=nil
    end
    
    @bmEvents = []
    @followedList = []
    if not @user.nil?
       @followedList = @user.followedLists.collect { |list| list.id }.flatten  
      @channels= Channel.where("user_id=?",@user.id)
      query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.main_bookmarks_list IS true AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

         
          queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
              e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              }
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"],
                :url => s["url"]
              }.values
              # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
              # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
              #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
              # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

              @bmEvents << item
            }


            #  Get RSVP Events
            query= "SELECT DISTINCT ON (recurrences.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
           WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.name ='Attending' AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NOT NULL AND  occurrences.start >= '#{Date.today()}'
            UNION
            SELECT DISTINCT ON (events.id,events.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences
              INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              INNER JOIN bookmark_lists ON  bookmarks.bookmark_list_id = bookmark_lists.id
            WHERE bookmark_lists.user_id = #{ @user.id } AND bookmark_lists.name ='Attending' AND bookmarks.bookmarked_type = 'Occurrence'  AND occurrences.recurrence_id IS NULL AND  occurrences.start >= '#{Date.today()}'
            "

          queryResult = ActiveRecord::Base.connection.select_all(query)
           # #puts queryResult
           @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq

           # #puts @eventIDs#puts
            @RSVP =[]
            @eventIDs.each{ |id|
              # #puts id
              # #puts "SET"
              set =  queryResult.select{ |r| r["event_id"] == id.to_s }
               # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
              e = Event.find(id)
              acts = e.acts
              act = []
              acts.each{ |a|
                tag_item = []
                tags = a.tags.collect { |tag| tag.name}
                unless a.pictures.first.nil?
                  tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
                else
                  tag_item  << a.name << a.id << tags << ""
                end
                
                act << tag_item

              }
               # act = set.collect { |s| { s["actor"],s["act_id"] }}.uniq 
              # Find the uniq recurrence id
              rec_ids = set.collect { |e| e["rec_id"] }.uniq
               rec = set.collect { |s| { 
                :every_other => s["every_other"], # 0
                :day_of_week => s["day_of_week"], # 1
                :week_of_month => s["week_of_month"], # 2 
                :day_of_month => s["day_of_month"],  # 3
                :rec_start => s["rec_start"],  # 4
                :rec_end => s["rec_end"]  # 5
                }.values
                }.uniq 
                # #puts rec
              # rec = set.collect { |s| {  s["every_other"], s["day_of_week"],s["week_of_month"],  s["day_of_month"] }}.uniq 
              
              s = set.first
              really_long_cache_name = "event_find_#{id}"
              tags = Rails.cache.read(really_long_cache_name)
              if (tags==nil)
                #puts "**************** No cache found for search event -id  ****************"
                tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
                Rails.cache.write(really_long_cache_name, tags)
                #puts "**************** Cache Set for search Query ****************"
              else
                #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
              end
              item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21,
                :user => [], #22
                :tps =>  [], #23
                :tix => s["tix"],
                :url => s["url"]
              }.values
              # item = {:act => act, :rec => rec , s["occurrence_start"] , s["end"] , s["cover"] , s["phone"],  s["description"],
              # s["title"], s["venue_name"], s["longitude"],s["latitude"], s["event_id"],  s["venue_id"],
              #  s["occurrence_id"], s["price"] ,  s["address"] ,  s["zip"] ,  s["city"],  s["state"] , s["clicks"],
              # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }

              @RSVP << item
            }




            # #puts esinfo.to_json

            @channels =  @channels.collect{|s| 
          {

          :end_date=> s.end_date,
          :id=> s.id,
          :start_date=> s.start_date,
          :end_days=> s.end_days,
          :end_seconds=> s.end_seconds,
          :excluded_tags=> s.excluded_tags,
          :high_price=> s.high_price,
          :user_id=> s.user_id,
          :included_tags=> s.included_tags,
          :low_price=> s.low_price,
          :name=> s.name,
          :option_day=> s.option_day,
          :start_days=> s.start_days,
          :start_seconds=> s.start_seconds
          }.values

         }
         @acts =  @user.bookmarked_acts.collect{|c|

          {
          :id=> c.id,
          :name=> c.name,
          }.values


         }
         @venues = @user.bookmarked_venues.collect{|c| 
          {
          :name=> c.name,
          :id=> c.id,
          :address => c.address,
          :city=> c.city ,
          :zip=> c.zip,
          :latitude=> c.latitude,
          :longitude=> c.longitude
          }.values


         }

    end

     
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>esinfo} }
      else
        
         format.json { render json: {user:@user, :RSVP =>@RSVP, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=> @followedList}}
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
  end
def SX
    #puts params[:email]
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 20
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end


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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end
    tmp ="0"
    tmp1 ="o"
    
    query = "SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match }
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match} AND occurrences.recurrence_id IS NOT NULL
            UNION
            SELECT DISTINCT ON (events.id,acts.id) occurrences.id AS occurrence_id, occurrences.start AS start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      #puts "queryResult 10 "
      occurrenceIDs =  queryResult.collect { |e| e["occurrence_id"].to_i }.uniq
      ttttmp = queryResult.sort_by{ |hsh| hsh["start"].to_datetime }
      esinfo = ttttmp.drop(@offset).take(@amount)
      ids =  esinfo.collect { |e| e["occurrence_id"].to_i }.uniq.join(',')
      # #puts esinfo


     query = "SELECT DISTINCT ON (recurrences.id,users.id,bookmark_lists.id) bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
             UNION
            SELECT DISTINCT ON (events.id,users.id,bookmark_lists.id) bookmark_lists.id AS listid, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (recurrences.id,acts.id) #{tmp} AS listid,#{tmp} AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})
            UNION
            SELECT DISTINCT ON (events.id,acts.id) #{tmp} AS listid, #{tmp} AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE occurrences.id IN (#{ids})"

    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    # #puts "queryResult------------------------"
    # #puts queryResult.to_json
    @ids = queryResult
    # #puts queryResult.uniq
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      users = set.select {|s| s["user_id"].to_i != 0}.collect{|s| s["user_id"].to_i}.uniq
      users = User.find(users).collect{|s| s.uid.to_s}.uniq
      
      tpids = set.collect { |e|  e["listid"].to_i}.uniq
      tps = BookmarkList.where(:id=>tpids,:featured=>true).collect{|l| l.picture.mini.url}.uniq
      
      # #puts tps
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => users, #22
                :tps =>  tps #23
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }

    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
   
    esinfo = esinfo.collect{|es| es.values}
    @amount = 10
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end

    # #puts esinfo.to_json
    #  Bookmarked events
    

     
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>esinfo} }
      else
        
         format.json { render json: {user:@user, channels: [],:bookmarked=>@bmEvents, :events => esinfo,:acts=>@acts, :venues=>@venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten  } }
         # format.json { render json: {user:@user, channels: @channels,:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

    end
    
  end


  def friendEvents
    tmp ="0"
    @ids = params[:ids].to_s.empty? ? nil : params[:ids].split(',')
    esinfo = []
    unless @ids.nil?
      tmps = "'#{@ids.join("','")}'"
      where_clause = "users.uid IN (#{tmps})"
      query ="SELECT events.event_url AS url, events.ticket_url AS tix,occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, 
              events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, 
              venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,
              recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, 
              recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, 
              venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start, users.lastname AS lastname,
              users.firstname AS firstname, users.uid AS uid, bookmarks.id AS bookmarked_id
              FROM recurrences 
              INNER JOIN events ON recurrences.event_id = events.id 
              INNER JOIN venues ON events.venue_id = venues.id 
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id 
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id 
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id 
              INNER JOIN occurrences ON events.id = occurrences.event_id 
              INNER JOIN bookmarks ON occurrences.id= bookmarks.bookmarked_id 
              INNER JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id 
              INNER JOIN users ON bookmark_lists.user_id = users.id 
              WHERE #{where_clause} AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS false AND bookmarks.bookmarked_type='Occurrence' AND bookmark_lists.main_bookmarks_list IS TRUE AND occurrences.recurrence_id IS NOT NULL 
              UNION SELECT events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, 
              events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, 
              venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, 
              #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, 
              events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, 
              events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start, users.lastname AS lastname,
              users.firstname AS firstname, users.uid AS uid, bookmarks.id AS bookmarked_id
              FROM events 
              INNER JOIN venues ON events.venue_id = venues.id 
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id 
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id 
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id 
              INNER JOIN occurrences ON events.id = occurrences.event_id 
              INNER JOIN bookmarks ON occurrences.id= bookmarks.bookmarked_id 
              INNER JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id 
              INNER JOIN users ON bookmark_lists.user_id = users.id 
              WHERE #{where_clause} AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS false AND bookmarks.bookmarked_type='Occurrence' AND bookmark_lists.main_bookmarks_list IS TRUE AND occurrences.recurrence_id IS NULL"
      really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
      queryResult = Rails.cache.read(really_long_cache_name)
      if (queryResult == nil)
        #puts "**************** No cache found for search query ****************"
        queryResult = ActiveRecord::Base.connection.select_all(query)
        Rails.cache.write(really_long_cache_name, queryResult)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query!!! ****************"
      end
      
      @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
      # #puts @eventIDs
      
      @eventIDs.each{ |id|
        # #puts id
        # #puts "SET"
        set =  queryResult.select{ |r| r["event_id"] == id.to_s }
        # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
        e = Event.find(id)
        acts = e.acts
        act = []
        acts.each{ |a|
          tag_item = []
          tags = a.tags.collect { |tag| tag.name}
          unless a.pictures.first.nil?
            tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
          else
            tag_item  << a.name << a.id << tags << ""
          end
          
          act << tag_item

        } 
        # act = set.collect { |s|  {s["actor"], s["act_id"]} }
        # Find the uniq recurrence id
        rec_ids = set.collect { |e| e["rec_id"] }.uniq
        rec = set.collect { |s| { 
          :every_other => s["every_other"],
          :day_of_week => s["day_of_week"],
          :week_of_month => s["week_of_month"], 
          :day_of_month => s["day_of_month"] ,
          :rec_start => s["rec_start"],  # 4
          :rec_end => s["rec_end"]  # 5

          }.values}.uniq 
        # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
        really_long_cache_name = "event_find_#{id}"
        tags = Rails.cache.read(really_long_cache_name)
        if (tags==nil)
          #puts "**************** No cache found for search event -id  ****************"
          tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
          Rails.cache.write(really_long_cache_name, tags)
          #puts "**************** Cache Set for search Query ****************"
        else
          #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
        end
        # #puts tags
        s = set.first
        lastname = s["lastname"].to_s
        firstname =s["firstname"].to_s
        name =  firstname+' '+lastname
        
        # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
        # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
        # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
        # :views => s["views"], :tags  =>  tags }

        item = {
                  :act => act, # 0
                  :rec => rec , # 1
                  :description => s["description"], # 2
                  :title => s["title"], # 3
                  :occurrence_id => s["occurrence_id"], #4
                  :cover => s["cover"] , #5
                  :venue_name => s["venue_name"], #6
                  :address => s["address"] , #7
                  :zip => s["zip"] , #8
                  :city => s["city"], #9
                  :state => s["state"] , #10
                  :phone => s["phone"], # 11
                  :lat => s["latitude"], # 12
                  :long => s["longitude"], #13
                  :venue_id => s["venue_id"], # 14
                  :price => s["price"] , #15
                  :views => s["views"],  #16
                  :clicks => s["clicks"], #17
                  :tags  => tags , # 18
                  :event_id => s["event_id"], #19
                  :start => s["occurrence_start"] , #20
                  :end => s["end"], #21
                  :name => name, # 22
                  :id => s["uid"], #23
                  :tix => s["tix"],
                  :url =>s["url"]
                }


        # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
        # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
        # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
        # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



        esinfo << item
      }
    end



    
    if esinfo.count == 0
       firstname = 'half past'
       lastname = 'now'
       uid = 'halfpastnow'
       query ="SELECT events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, 
            events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, 
            venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, 
            #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, 
            events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, 
            events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start, '#{lastname}' AS lastname,
            '#{firstname}' AS firstname, '#{uid}' AS uid, #{tmp} AS bookmarked_id
            FROM events 
            INNER JOIN venues ON events.venue_id = venues.id 
            LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id 
            LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id 
            LEFT OUTER JOIN acts ON acts.id = acts_events.act_id 
            INNER JOIN occurrences ON events.id = occurrences.event_id 
            WHERE occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS false AND occurrences.id IN (166014)"
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
      s = set.first
      lastname = s["lastname"].to_s
      firstname =s["firstname"].to_s
      name =  firstname+' '+lastname
      
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :name => name, # 22
                :id => s["uid"], #23
                :tix => s["tix"],
                :url => s["url"]
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }
    end
    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.collect{|es| es.values}
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: {:events=>esinfo} }
    end

  end


  def friendRSVPEvents
    
    tmp ="0"
    @ids = params[:ids].to_s.empty? ? nil : params[:ids].split(',')
    tmps = "'#{@ids.join("','")}'"
    where_clause = "users.uid IN (#{tmps})"
    query ="SELECT events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, 
            events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, 
            venues.state AS state,venues.zip AS zip, venues.city AS city, recurrences.start AS rec_start, recurrences.end AS rec_end, recurrences.every_other AS every_other,
            recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, 
            recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, 
            venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start, users.lastname AS lastname,
            users.firstname AS firstname, users.uid AS uid, bookmarks.bookmarked_id AS bookmarked_id
            FROM recurrences 
            INNER JOIN events ON recurrences.event_id = events.id 
            INNER JOIN venues ON events.venue_id = venues.id 
            LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id 
            LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id 
            LEFT OUTER JOIN acts ON acts.id = acts_events.act_id 
            INNER JOIN occurrences ON events.id = occurrences.event_id 
            INNER JOIN bookmarks ON occurrences.id= bookmarks.bookmarked_id 
            INNER JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id 
            INNER JOIN users ON bookmark_lists.user_id = users.id 
            WHERE #{where_clause} AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS false AND bookmark_lists.name ='Attending' AND bookmarks.bookmarked_type='Occurrence' AND occurrences.recurrence_id IS NOT NULL 
            UNION SELECT events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, 
            events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, 
            venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, 
            #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, 
            events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, 
            events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start, users.lastname AS lastname,
            users.firstname AS firstname, users.uid AS uid, bookmarks.bookmarked_id AS bookmarked_id
            FROM events 
            INNER JOIN venues ON events.venue_id = venues.id 
            LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id 
            LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id 
            LEFT OUTER JOIN acts ON acts.id = acts_events.act_id 
            INNER JOIN occurrences ON events.id = occurrences.event_id 
            INNER JOIN bookmarks ON occurrences.id= bookmarks.bookmarked_id 
            INNER JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id 
            INNER JOIN users ON bookmark_lists.user_id = users.id 
            WHERE #{where_clause} AND occurrences.start >= '#{Date.today()}' AND occurrences.deleted IS false AND bookmarks.bookmarked_type='Occurrence' AND bookmark_lists.name ='Attending' AND occurrences.recurrence_id IS NULL"
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    
    @eventIDs =  queryResult.collect { |e| e["bookmarked_id"] }.uniq
    # #puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # #puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["bookmarked_id"] == id.to_s }
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
      e = Occurrence.find(id).event
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      } 
      # act = set.collect { |s|  {s["actor"], s["act_id"]} }
      # Find the uniq recurrence id
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      # tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
      tags  = Occurrence.find(id).event.tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
      # #puts tags
      s = set.first
      lastname = s["lastname"].to_s
      firstname =s["firstname"].to_s
      name =  firstname+' '+lastname
      
      # item = {:act => act, :rec => rec , :start => s["occurrence_start"] , :end => s["end"] ,:cover => s["cover"] , :phone => s["phone"], :description => s["description"],
      # :title => s["title"], :venue_name => s["venue_name"],:long => s["longitude"], :lat => s["latitude"], :event_id => s["event_id"], :venue_id => s["venue_id"],
      # :occurrence_id => s["occurrence_id"], :price => s["price"] , :address => s["address"] , :zip => s["zip"] , :city => s["city"], :state => s["state"] ,:clicks => s["clicks"],
      # :views => s["views"], :tags  =>  tags }

      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :name => name, # 22
                :id => s["uid"], #23
                :tix => s["tix"],
                :url =>s["url"]
              }


      # item = {:act => act, :rec => rec , s["occurrence_start"] ,  s["end"] ,s["cover"] , s["phone"], s["description"],
      # ["title"],  s["venue_name"],s["longitude"], s["latitude"], s["event_id"],  s["venue_id"],
      # s["occurrence_id"], s["price"] ,s["address"] ,  s["zip"] , s["city"], s["state"] , s["clicks"],
      # s["views"], :tags  => Event.find(id).tags.collect{ |t| {t.id, t.name}}  }



      esinfo << item
    }

    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.collect{|es| es.values}
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: {:events=>esinfo} }
    end

  end


  
  def tpevents1
    tmp ="0"

    @ids = params[:ids].to_s.empty? ? nil : params[:ids].split(',')
    @lists = BookmarkList.find(@ids)
    esinfo = []
    @occurrences =[]
    @lists.each{
      |list|
      @occurrences = list.all_bookmarked_events.collect{|o| {:id =>o.id, :start => o.start , :list => list, :event_id => o.event_id} }

    }
    #puts @occurrences

    ttttmp = @occurrences.sort_by{ |hsh| hsh[:start] }
    
    @occurrencesid = ttttmp.drop(0).take(10).collect{|o| o[:id]}
    
    if @occurrencesid.size > 0
          where_clause = "occurrences.id IN (#{@occurrencesid.join(',')})"
          query = "SELECT DISTINCT ON (recurrences.id,acts.id) occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
                  FROM occurrences
                  INNER JOIN events ON occurrences.event_id = events.id
                  INNER JOIN venues ON events.venue_id = venues.id
                  LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                  INNER JOIN recurrences ON events.id = recurrences.event_id
                  LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                  LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                  INNER JOIN tags ON events_tags.tag_id = tags.id
                  WHERE #{where_clause} AND occurrences.recurrence_id IS NOT NULL
                  UNION 
                  SELECT DISTINCT ON (events.id,acts.id) occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
                  FROM occurrences
                  INNER JOIN events ON occurrences.event_id = events.id
                  INNER JOIN venues ON events.venue_id = venues.id
                  LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                  LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                  LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                  INNER JOIN tags ON events_tags.tag_id = tags.id
                  WHERE #{where_clause} AND occurrences.recurrence_id IS NULL
                  "
          really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
          queryResult = Rails.cache.read(really_long_cache_name)
          if (queryResult == nil)
            #puts "**************** No cache found for search query ****************"
            queryResult = ActiveRecord::Base.connection.select_all(query)
            Rails.cache.write(really_long_cache_name, queryResult)
            #puts "**************** Cache Set for search Query ****************"
          else
            #puts "**************** Cache FOUND for search query!!! ****************"
          end
          # #puts queryResult
          @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
          
          @eventIDs.each{ |id|
            set =  queryResult.select{ |r| r["event_id"] == id.to_s }
            oc = @occurrences.select { |o| o[:event_id]=id}.first
            
            # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
            e = Event.find(id)
            acts = e.acts
            act = []
            acts.each{ |a|
              tag_item = []
              tags = a.tags.collect { |tag| tag.name}
              unless a.pictures.first.nil?
                tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
              else
                tag_item  << a.name << a.id << tags << ""
              end
              
              act << tag_item

            }
            rec_ids = set.collect { |e| e["rec_id"] }.uniq
            rec = set.collect { |s| { 
              :every_other => s["every_other"],
              :day_of_week => s["day_of_week"],
              :week_of_month => s["week_of_month"], 
              :day_of_month => s["day_of_month"] ,
              :rec_start => s["rec_start"],  # 4
              :rec_end => s["rec_end"]  # 5

              }.values}.uniq 
            really_long_cache_name = "event_find_#{id}"
            tags = Rails.cache.read(really_long_cache_name)
            if (tags==nil)
              #puts "**************** No cache found for search event -id  ****************"
              tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
              Rails.cache.write(really_long_cache_name, tags)
              #puts "**************** Cache Set for search Query ****************"
            else
              #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
            end
            s = set.first
            
            item = {
                      :act => act, # 0
                      :rec => rec , # 1
                      :description => s["description"], # 2
                      :title => s["title"], # 3
                      :occurrence_id => s["occurrence_id"], #4
                      :cover => s["cover"] , #5
                      :venue_name => s["venue_name"], #6
                      :address => s["address"] , #7
                      :zip => s["zip"] , #8
                      :city => s["city"], #9
                      :state => s["state"] , #10
                      :phone => s["phone"], # 11
                      :lat => s["latitude"], # 12
                      :long => s["longitude"], #13
                      :venue_id => s["venue_id"], # 14
                      :price => s["price"] , #15
                      :views => s["views"],  #16
                      :clicks => s["clicks"], #17
                      :tags  => tags , # 18
                      :event_id => s["event_id"], #19
                      :start => s["occurrence_start"] , #20
                      :end => s["end"], #21
                      :tp => oc[:list].name #22
                      
                    }
            esinfo << item

          }
      end




    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.collect{|es| es.values}

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: {:events=>esinfo} }
    end


  end
  


  def tpevents
    tmp ="0"

    @ids = params[:ids].to_s.empty? ? nil : params[:ids].split(',')
    @lists = BookmarkList.find(@ids)
    esinfo = []
    @lists.each{
      |list|
      @occurrencesid = list.all_bookmarked_events.collect{|o| o.id}
      #puts "Bookmark"
      # #puts list.all_bookmarked_events
      if @occurrencesid.size > 0
          where_clause = "occurrences.id IN (#{@occurrencesid.join(',')})"
          query = "SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
                  FROM occurrences
                  INNER JOIN events ON occurrences.event_id = events.id
                  INNER JOIN venues ON events.venue_id = venues.id
                  LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                  INNER JOIN recurrences ON events.id = recurrences.event_id
                  LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                  LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                  INNER JOIN tags ON events_tags.tag_id = tags.id
                  WHERE #{where_clause} AND occurrences.recurrence_id IS NOT NULL
                  UNION 
                  SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
                  FROM occurrences
                  INNER JOIN events ON occurrences.event_id = events.id
                  INNER JOIN venues ON events.venue_id = venues.id
                  LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                  LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                  LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                  INNER JOIN tags ON events_tags.tag_id = tags.id
                  WHERE #{where_clause} AND occurrences.recurrence_id IS NULL
                  "
          # #puts query
          really_long_cache_name = Digest::SHA1.hexdigest("search_for_uniq_#{query}")
          queryResult = Rails.cache.read(really_long_cache_name)
          if (queryResult == nil)
            #puts "**************** No cache found for search query ****************"
            queryResult = ActiveRecord::Base.connection.select_all(query).uniq
            Rails.cache.write(really_long_cache_name, queryResult)
            #puts "**************** Cache Set for search Query ****************"
          else
            #puts "**************** Cache FOUND for search query!!! ****************"
          end
          
          # #puts queryResult
          @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
          
          @eventIDs.each{ |id|
            set =  queryResult.select{ |r| r["event_id"] == id.to_s }
            # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
            e = Event.find(id)
            acts = e.acts
            act = []
            acts.each{ |a|
              tag_item = []
              tags = a.tags.collect { |tag| tag.name}
              unless a.pictures.first.nil?
                tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
              else
                tag_item  << a.name << a.id << tags << ""
              end
              
              act << tag_item

            } 
            rec_ids = set.collect { |e| e["rec_id"] }.uniq
            rec = set.collect { |s| { 
              :every_other => s["every_other"],
              :day_of_week => s["day_of_week"],
              :week_of_month => s["week_of_month"], 
              :day_of_month => s["day_of_month"] ,
              :rec_start => s["rec_start"],  # 4
              :rec_end => s["rec_end"]  # 5

              }.values}.uniq 
            really_long_cache_name = "event_find_#{id}"
            tags = Rails.cache.read(really_long_cache_name)
            if (tags==nil)
              #puts "**************** No cache found for search event -id  ****************"
              tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
              Rails.cache.write(really_long_cache_name, tags)
              #puts "**************** Cache Set for search Query ****************"
            else
              #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
            end
            s = set.first
            if s["latitude"].nil?
               s["latitude"] = "30.2003363"
            end
            if s["longitude"].nil?
               s["longitude"] = "-97.7683374"
            end

            item = {
                      :act => act, # 0
                      :rec => rec , # 1
                      :description => s["description"], # 2
                      :title => s["title"], # 3
                      :occurrence_id => s["occurrence_id"], #4
                      :cover => s["cover"] , #5
                      :venue_name => s["venue_name"], #6
                      :address => s["address"] , #7
                      :zip => s["zip"] , #8
                      :city => s["city"], #9
                      :state => s["state"] , #10
                      :phone => s["phone"], # 11
                      :lat => s["latitude"], # 12
                      :long => s["longitude"], #13
                      :venue_id => s["venue_id"], # 14
                      :price => s["price"] , #15
                      :views => s["views"],  #16
                      :clicks => s["clicks"], #17
                      :tags  => tags , # 18
                      :event_id => s["event_id"], #19
                      :start => s["occurrence_start"] , #20
                      :end => s["end"], #21
                      :tp => list.name #22
                     
                    }
            esinfo << item

          }
      end
      


    
    }

    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.collect{|es| es.values}

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: {:events=>esinfo} }
    end


  end

  def tpeventsSX
    tmp ="0"

    @ids = params[:ids].to_s.empty? ? nil : params[:ids].split(',')
    @lists = BookmarkList.find(@ids)
    esinfo = []
    @lists.each{
      |list|
      @occurrencesid = list.all_bookmarked_events.collect{|o| o.id}
      #puts "Bookmark"
      # #puts list.all_bookmarked_events
      if @occurrencesid.size > 0
          where_clause = "occurrences.id IN (#{@occurrencesid.join(',')})"
          query = "SELECT DISTINCT ON (recurrences.id,acts.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
                  FROM occurrences
                  INNER JOIN events ON occurrences.event_id = events.id
                  INNER JOIN venues ON events.venue_id = venues.id
                  LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                  INNER JOIN recurrences ON events.id = recurrences.event_id
                  LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                  LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                  INNER JOIN tags ON events_tags.tag_id = tags.id
                  WHERE #{where_clause} AND occurrences.recurrence_id IS NOT NULL
                  UNION 
                  SELECT DISTINCT ON (events.id,acts.id) events.event_url AS url,events.ticket_url AS tix, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
                  FROM occurrences
                  INNER JOIN events ON occurrences.event_id = events.id
                  INNER JOIN venues ON events.venue_id = venues.id
                  LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                  LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                  LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                  INNER JOIN tags ON events_tags.tag_id = tags.id
                  WHERE #{where_clause} AND occurrences.recurrence_id IS NULL
                  "
          # #puts query
          really_long_cache_name = Digest::SHA1.hexdigest("search_for_uniq_#{query}")
          queryResult = Rails.cache.read(really_long_cache_name)
          if (queryResult == nil)
            #puts "**************** No cache found for search query ****************"
            queryResult = ActiveRecord::Base.connection.select_all(query).uniq
            Rails.cache.write(really_long_cache_name, queryResult)
            #puts "**************** Cache Set for search Query ****************"
          else
            #puts "**************** Cache FOUND for search query!!! ****************"
          end
          # #puts queryResult
          @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
          
          @eventIDs.each{ |id|
            set =  queryResult.select{ |r| r["event_id"] == id.to_s }
            # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
            e = Event.find(id)
            acts = e.acts
            act = []
            acts.each{ |a|
              tag_item = []
              tags = a.tags.collect { |tag| tag.name}
              unless a.pictures.first.nil?
                tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
              else
                tag_item  << a.name << a.id << tags << ""
              end
              
              act << tag_item

            } 
            rec_ids = set.collect { |e| e["rec_id"] }.uniq
            rec = set.collect { |s| { 
              :every_other => s["every_other"],
              :day_of_week => s["day_of_week"],
              :week_of_month => s["week_of_month"], 
              :day_of_month => s["day_of_month"] ,
              :rec_start => s["rec_start"],  # 4
              :rec_end => s["rec_end"]  # 5

              }.values}.uniq 
            really_long_cache_name = "event_find_#{id}"
            tags = Rails.cache.read(really_long_cache_name)
            if (tags==nil)
              #puts "**************** No cache found for search event -id  ****************"
              tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
              Rails.cache.write(really_long_cache_name, tags)
              #puts "**************** Cache Set for search Query ****************"
            else
              #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
            end
            s = set.first
            if s["latitude"].nil?
               s["latitude"] = "30.2003363"
            end
            if s["longitude"].nil?
               s["longitude"] = "-97.7683374"
            end

            item = {
                      :act => act, # 0
                      :rec => rec , # 1
                      :description => s["description"], # 2
                      :title => s["title"], # 3
                      :occurrence_id => s["occurrence_id"], #4
                      :cover => s["cover"] , #5
                      :venue_name => s["venue_name"], #6
                      :address => s["address"] , #7
                      :zip => s["zip"] , #8
                      :city => s["city"], #9
                      :state => s["state"] , #10
                      :phone => s["phone"], # 11
                      :lat => s["latitude"], # 12
                      :long => s["longitude"], #13
                      :venue_id => s["venue_id"], # 14
                      :price => s["price"] , #15
                      :views => s["views"],  #16
                      :clicks => s["clicks"], #17
                      :tags  => tags , # 18
                      :event_id => s["event_id"], #19
                      :start => s["occurrence_start"] , #20
                      :end => s["end"], #21
                      :tp => list.name, #22
                      :tix => s["tix"],
                      :url => s["url"]
                    }
            esinfo << item

          }
      end
      


    
    }

    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.collect{|es| es.values}

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: {:events=>esinfo} }
    end


  end
  

  def tpeventsSX1
    tmp ="0"

    @ids = params[:ids].to_s.empty? ? nil : params[:ids].split(',')
    @ids = @ids.join(',')
    esinfo = []



    query = "SELECT DISTINCT ON (recurrences.id) bookmark_lists.name AS lname, events.event_url AS url,events.ticket_url AS tix, bookmark_lists.id AS listid, bookmark_lists.picture AS pix, users.id AS user_id, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN recurrences ON events.id = recurrences.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE bookmark_lists.id IN (#{@ids}) AND bookmark_lists.featured IS NOT FALSE AND occurrences.recurrence_id IS NOT NULL AND (recurrences.range_end >= '#{Date.today()}' OR recurrences.range_end IS NULL)
            UNION
            SELECT DISTINCT ON (events.id) bookmark_lists.name AS lname, events.event_url AS url,events.ticket_url AS tix,bookmark_lists.id AS listid, bookmark_lists.picture AS pix, users.id AS user_id, occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM users
              INNER JOIN bookmark_lists ON users.id = bookmark_lists.user_id
              INNER JOIN bookmarks ON bookmark_lists.id =bookmarks.bookmark_list_id 
              INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id  
              INNER JOIN events ON occurrences.event_id = events.id
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE bookmark_lists.id IN (#{@ids}) AND bookmark_lists.featured IS NOT FALSE AND occurrences.start >= '#{Date.today()}' AND occurrences.recurrence_id IS NULL
            "

   
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_uniq_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query).uniq
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end 
          # #puts queryResult
          @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
          
          @eventIDs.each{ |id|
            set =  queryResult.select{ |r| r["event_id"] == id.to_s }
            # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq
            e = Event.find(id)
            acts = e.acts
            act = []
            acts.each{ |a|
              tag_item = []
              tags = a.tags.collect { |tag| tag.name}
              unless a.pictures.first.nil?
                tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
              else
                tag_item  << a.name << a.id << tags << ""
              end
              
              act << tag_item

            } 
            rec_ids = set.collect { |e| e["rec_id"] }.uniq
            rec = set.collect { |s| { 
              :every_other => s["every_other"],
              :day_of_week => s["day_of_week"],
              :week_of_month => s["week_of_month"], 
              :day_of_month => s["day_of_month"] ,
              :rec_start => s["rec_start"],  # 4
              :rec_end => s["rec_end"]  # 5

              }.values}.uniq 
            really_long_cache_name = "event_find_#{id}"
            tags = Rails.cache.read(really_long_cache_name)
            if (tags==nil)
              #puts "**************** No cache found for search event -id  ****************"
              tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
              Rails.cache.write(really_long_cache_name, tags)
              #puts "**************** Cache Set for search Query ****************"
            else
              #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
            end
            s = set.first
            if s["latitude"].nil?
               s["latitude"] = "30.2003363"
            end
            if s["longitude"].nil?
               s["longitude"] = "-97.7683374"
            end

            item = {
                      :act => act, # 0
                      :rec => rec , # 1
                      :description => s["description"], # 2
                      :title => s["title"], # 3
                      :occurrence_id => s["occurrence_id"], #4
                      :cover => s["cover"] , #5
                      :venue_name => s["venue_name"], #6
                      :address => s["address"] , #7
                      :zip => s["zip"] , #8
                      :city => s["city"], #9
                      :state => s["state"] , #10
                      :phone => s["phone"], # 11
                      :lat => s["latitude"], # 12
                      :long => s["longitude"], #13
                      :venue_id => s["venue_id"], # 14
                      :price => s["price"] , #15
                      :views => s["views"],  #16
                      :clicks => s["clicks"], #17
                      :tags  => tags , # 18
                      :event_id => s["event_id"], #19
                      :start => s["occurrence_start"] , #20
                      :end => s["end"], #21
                      :tp => s["lname"], #22
                      :tix => s["tix"],
                      :url => s["url"]
                    }
            esinfo << item
          }

    
    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.collect{|es| es.values}

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      format.json { render json: {:events=>esinfo} }
    end


  end

  def FBlogin

    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"
    bookmarked = !params[:bookmark_type].to_s.empty?
    # amount/offset
    @amount = 20
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end


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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end
    
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end

    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
      days_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
    end

    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{days_check}"


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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end

    # the big enchilada
    query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM occurrences 
              INNER JOIN events ON occurrences.event_id = events.id
              INNER JOIN venues ON events.venue_id = venues.id
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
            WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"

    # #puts "FBlogin"
    # #puts query
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    @ids = queryResult
    
    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    # @allOccurrences = Occurrence.includes(:event => :tags, :event => :venue, :event => :occurrences, :event => :recurrences).find(@occurrence_ids, :order => order_by)
    
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_allOccurrences_#{@occurrence_ids}")
    @allOccurrences = Rails.cache.read(really_long_cache_name)
    if (@allOccurrences == nil)
      puts "**************** No cache found for search query allOccurrences ****************"
      @allOccurrences = Occurrence.includes(:event => :tags, :event => :venue, :event => :occurrences, :event => :recurrences).find(@occurrence_ids, :order => order_by)
    
      Rails.cache.write(really_long_cache_name, @allOccurrences)
      puts "**************** Cache Set for search Query allOccurrences ****************"
    else
      puts "**************** Cache FOUND for search query!!! allOccurrences ****************"
    end



    @occurrences = @allOccurrences.drop(@offset).take(@amount)

    # generating tag list for occurrences

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

    
    # pp @occurringTags
    # #puts ""
    # #puts "- - - - - - - - - - - - -"
    # #puts ""
    # @occurringTags.each do |id,tuple|
    #   pp tuple[:tag]
    #   pp tuple[:tag].childTags
    # end
    # #puts "_________________________"
    # #puts ""

    if @event_ids.size > 0
      ActiveRecord::Base.connection.update("UPDATE events
        SET views = views + 1
        WHERE id IN (#{@event_ids * ','})")

      ActiveRecord::Base.connection.update("UPDATE venues
        SET views = views + 1
        WHERE id IN (#{@venue_ids * ','})")
    end
    # 2 cases - Non registerd user, registered user  
    # case 1 - params[:email] empty - return all event only
    # case 2 - params[:email] not empty - return bookmarks, customized channels, and all events
    email = params[:email]
      
    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user = nil
    end
    @tagss = Tag.all.collect{|t| [t.id,t.name]}
    @tagss = Tag.all.sort_by do |tag|
        tag.id
    end
    if not @user.nil?
      @channels= Channel.where("user_id=?",@user.id)
      
      @tags = @tagss.collect{|t| [t.id,t.name]}
      @bookmarks= Bookmark.where("user_id=?",@user.id)
      @occurrenceids= @user.bookmarked_events.collect(&:id)
      # @eventids = Occurrence.find(@occurrenceids).collect(&:event_id)
      # @tmps = Occurrence.find(@occurrenceids)
      # @events = Event.includes(:tags, :venue, :recurrences,:acts).find(@eventids) 
      # @eventinfo =[]
      # @events.each{
      #   |o| 
      #   @rcs=Recurrence.find(o.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq)
      #   @ocs=o.occurrences.select{|o| o.recurrence_id==nil}
      #   @item = {event: o, tags: o.tags, venue: o.venue, recurrences: @rcs, occurrences: @ocs, act: o.acts}
      #   @eventinfo << @item
      # }


      @eventinfo =[]
      @occurrenceids.each{
        |oid|
        @eventids = Occurrence.find(oid).event_id
        @events = Event.includes(:tags, :venue, :recurrences,:acts).find(@eventids) 
        @rcs=Recurrence.find(@events.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq)
        @ocs=@events.occurrences.select{|o| o.recurrence_id==nil}
        @item = {event: @events, tags: @events.tags, venue: @events.venue, recurrences: @rcs, occurrences: @ocs, act: @events.acts,ocid: oid}
        @eventinfo << @item
      }


    end
    # Create events from occurrence
    @es = @occurrences.collect { |occ| occ.event }
    @esinfo =[]
    @eventinfo =[]
    @es.each{
      |o| 
      @rcs=Recurrence.find(o.occurrences.select{|o| o.recurrence_id!=nil }.collect(&:recurrence_id).uniq)
      @ocs=o.occurrences.select{|o| o.recurrence_id==nil}
      @item = {event: o, tags: o.tags, venue: o.venue, recurrences: @rcs, occurrences: @ocs, act: o.acts}
      @esinfo << @item
    }
    #puts "esinfo"
    @channels =  @channels.collect{|s| 
          {

          :end_date=> s.end_date,
          :id=> s.id,
          :start_date=> s.start_date,
          :end_days=> s.end_days,
          :end_seconds=> s.end_seconds,
          :excluded_tags=> s.excluded_tags,
          :high_price=> s.high_price,
          :user_id=> s.user_id,
          :included_tags=> s.included_tags,
          :low_price=> s.low_price,
          :name=> s.name,
          :option_day=> s.option_day,
          :start_days=> s.start_days,
          :start_seconds=> s.start_seconds
          }.values
        }
    @channels=[]
    @esinfo=[]
    @es
    # #puts @esinfo.to_json
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>@esinfo} }
      else 
        format.json { render json: {user:@user, channels: [],:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues, :listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end

  end

    


    

  end

  def newFBLogin
    unless(params[:channel_id].to_s.empty?)
      channel = Channel.find(params[:channel_id].to_i)

      params[:option_day] ||= channel.option_day || 0
      params[:start_days] ||= channel.start_days || ""
      params[:end_days] ||= channel.end_days || ""
      params[:start_seconds] ||= channel.start_seconds || ""
      params[:end_seconds] ||= channel.end_seconds || ""
      params[:low_price] ||= channel.low_price || ""
      params[:high_price] ||= channel.high_price || ""
      params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
      params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
      params[:lat_min] ||= ""
      params[:lat_max] ||= ""
      params[:long_min] ||= ""
      params[:long_max] ||= ""
      params[:offset] ||= 0
      params[:search] ||= ""
      params[:sort] ||= channel.sort || 0
      params[:name] ||= channel.name || ""
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end
   
    # pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.includes(:parentTag, :childTags).all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"

    bookmarked = !params[:bookmark_type].to_s.empty?

    # amount/offset
    @amount = 20
    unless(params[:amount].to_s.empty?)
      @amount = params[:amount].to_i
    end

    @offset = 0
    unless(params[:offset].to_s.empty?)
      @offset = params[:offset].to_i
    end


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

    event_start_date = event_end_date = nil
    if(!params[:start_date].to_s.empty?)
      event_start_date = Date.parse(params[:start_date])
    else
      event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    end
    if(!params[:end_date].to_s.empty?)
      event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
    else
      event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_i == -1) ? 365000 : params[:end_days].to_i + 1))
    end

    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    unless(params[:start_seconds].to_s.empty? && params[:end_seconds].to_s.empty?)
      event_start_time = params[:start_seconds].to_s.empty? ? 0 : params[:start_seconds].to_i
      event_end_time = params[:end_seconds].to_s.empty? ? 86400 : params[:end_seconds].to_i

      start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
      end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
    end


    unless(params[:day].to_s.empty?)
      # event_days = params[:day].to_s.empty? ? nil : params[:day].collect { |day| day.to_i } * ','
      event_days = params[:day].to_s.empty? ? nil : params[:day].to_s
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

      # tag_include_match = "events.id IN (
      #               SELECT event_id 
      #                 FROM events, tags, events_tags 
      #                 WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
      #                 GROUP BY event_id 
      #                 HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
      #             )"

      tag_include_match = "tags.id IN (#{tags_mush})"
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

    # pricet
    unless(params[:low_price].to_s.empty?)
      low_price = params[:low_price].to_i
      low_price_match = "events.price >= #{low_price}"
    end

    unless(params[:high_price].to_s.empty?)
      high_price = params[:high_price].to_i
      high_price_match = "events.price <= #{high_price}"
    end

    order_by = "occurrences.start"
    if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      # order by event score when sorting by popularity
      order_by = "CASE events.views 
                    WHEN 0 THEN 0
                    ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"
    end

    # the big enchilada
    if(bookmarked)
      user_id = current_user.id

      if(params[:bookmark_type] == "event")
        query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences 
                INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN venues ON events.venue_id = venues.id
                INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
              WHERE bookmarks.user_id = #{user_id} AND bookmarks.bookmarked_type = 'Occurrence'"
      elsif(params[:bookmark_type] == "venue")
        query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences 
                INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN venues ON events.venue_id = venues.id
                INNER JOIN bookmarks ON venues.id = bookmarks.bookmarked_id
              WHERE bookmarks.user_id = #{user_id} AND bookmarks.bookmarked_type = 'Venue'"
      elsif(params[:bookmark_type] == "act")
        query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences 
                INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN venues ON events.venue_id = venues.id
                LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                INNER JOIN bookmarks ON acts.id = bookmarks.bookmarked_id
              WHERE bookmarks.user_id = #{user_id} AND bookmarks.bookmarked_type = 'Act'"
      end
    else
      query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences 
                INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN venues ON events.venue_id = venues.id
                LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id
              WHERE #{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{low_price_match} AND #{high_price_match}"
    end
    #puts "newFBLogin"
    # #puts query
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    @ids = queryResult

    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    really_long_cache_name = Digest::SHA1.hexdigest("search_for_allOccurrences_#{@occurrence_ids}")
    @allOccurrences = Rails.cache.read(really_long_cache_name)
    if (@allOccurrences == nil)
      puts "**************** No cache found for search query allOccurrences ****************"
      @allOccurrences = Occurrence.includes(:event => :tags, :event => :venue, :event => :occurrences, :event => :recurrences).find(@occurrence_ids, :order => order_by)
    
      Rails.cache.write(really_long_cache_name, @allOccurrences)
      puts "**************** Cache Set for search Query allOccurrences ****************"
    else
      puts "**************** Cache FOUND for search query!!! allOccurrences ****************"
    end
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

    

    # 2 cases - Non registerd user, registered user  
    # case 1 - params[:email] empty - return all event only
    # case 2 - params[:email] not empty - return bookmarks, customized channels, and all events
    email = params[:email]
     
    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user = nil
    end
    @tagss = Tag.all.collect{|t| [t.id,t.name]}
    @tagss = Tag.all.sort_by do |tag|
        tag.id
    end
    if not @user.nil?
      @channels= Channel.where("user_id=?",@user.id)
      
      @tags = @tagss.collect{|t| [t.id,t.name]}
      @bookmarks= Bookmark.where("user_id=?",@user.id)
      @occurrenceids= @user.bookmarked_events.collect(&:id)

      @eventinfo =[]
      @occurrenceids.each{
        |oid|
        @eventids = Occurrence.find(oid).event_id
        @events = Event.includes(:tags, :venue, :recurrences,:acts).find(@eventids) 
        @rcs=Recurrence.find(@events.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq)
        @ocs=@events.occurrences.select{|o| o.recurrence_id==nil}
        @item = {event: @events, tags: @events.tags, venue: @events.venue, recurrences: @rcs, occurrences: @ocs, act: @events.acts,ocid: oid}
        @eventinfo << @item
      }



      # @eventids = Occurrence.find(@occurrenceids).collect(&:event_id)
      # @tmps = Occurrence.find(@occurrenceids)
      # @events = Event.includes(:tags, :venue, :recurrences,:acts).find(@eventids) 
      # @eventinfo =[]
      # @i=0
      # @events.each{
      #   |o| 
      #   @rcs=Recurrence.find(o.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq)
      #   @ocs=o.occurrences.select{|o| o.recurrence_id==nil}
      #   @item = {event: o, tags: o.tags, venue: o.venue, recurrences: @rcs, occurrences: @ocs, act: o.acts,ocid: @occurrenceids[@i]}
      #   @eventinfo << @item
      #   @i=@i+1
      # }
      # @item ={ocid:@occurrenceids}
      # @eventinfo << @item
    end
    # Create events from occurrence
    @es = @occurrences.collect { |occ| occ.event }
    @esinfo =[]
    @es.each{
      |o| 
      @rcs=Recurrence.find(o.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq)
      @ocs=o.occurrences.select{|o| o.recurrence_id==nil}
      @item = {event: o, tags: o.tags, venue: o.venue, recurrences: @rcs, occurrences: @ocs, act: o.acts}
      @esinfo << @item
    }

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :tagCounts => @tagCounts, :parentTags => @parentTags, :offset => @offset }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: {:events=>@esinfo} }
      else 
        format.json { render json: {user:@user, channels: [],:bookmarked =>@eventinfo,:events=>@esinfo,:acts=>@user.bookmarked_acts, :venues=>@user.bookmarked_venues,:listids=>@user.followedLists.collect { |list| list.id }.flatten }} 
        # format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      
      end
    end
    
  end

  def eventsList
    email = params[:email]
     
    unless email.nil?
      @user=User.find_by_email(email.downcase)
    else
      @user=nil
      
    end
    # @occurrences = @user.followedLists.collect { |list| list.bookmarked_events }.flatten
    # @es = @occurrences.collect { |occ| occ.event }
    # @esinfo =[]
    # @es.each{
    #   |o| 
    #   @rcs=Recurrence.find(o.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq)
    #   @ocs=o.occurrences.select{|o| o.recurrence_id==nil}
    #   @item = {event: o, tags: o.tags, venue: o.venue, recurrences: @rcs, occurrences: @ocs, act: o.acts}
    #   @esinfo << @item
    # }
    # respond_to do |format|
    #   format.json { render json: { :events =>@esinfo  } } 
    # end
    @ids = params[:ids].to_s.empty? ? nil : params[:ids].split(',')
    @lists = BookmarkList.find(@ids)
    @esinfo =[]
    @lists.each{
      |list|
      @occurrences = list.all_bookmarked_events
      @es = @occurrences.collect { |occ| occ.event }
      @tmps =[]
      @es.each{
        |o| 
        @rcs=Recurrence.find(o.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq)
        @ocs=o.occurrences.select{|o| o.recurrence_id==nil}
        @item = {event: o, tags: o.tags, venue: o.venue, recurrences: @rcs, occurrences: @ocs, act: o.acts,tp: list.name}
        @esinfo << @item
      }
      

    }
    respond_to do |format|
      format.json { render json: { :events =>@esinfo  } } 
    end

  end

  def showVenue
    @venue = Venue.find(params[:id])
    @venue.clicks += 1
    @venue.save
    @occurrences  = []
    @recurrences = []
    startTime = Date.today()

    endTime = startTime.advance(:days =>7)
   
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_venue_#{params[:id]}_#{startTime}")
    @occs =  Rails.cache.read(really_long_cache_name)
    if (@occs == nil)
      #puts "**************** No cache found for search query ****************"
      @occs = @venue.events.collect { |event| event.occurrences.select { |occ| occ.start >= startTime &&  occ.start <= endTime}  }.flatten.sort_by { |occ| occ.start }
      Rails.cache.write(really_long_cache_name, @occs)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
         

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
    @recurrences.reject! { |c| c.nil? }
    @occurrences.reject! { |c| c.nil? }
    @eventidsocc = @occurrences.collect(&:event_id)
    @eventidsrec = @recurrences.collect(&:event_id)

    really_long_cache_name = Digest::SHA1.hexdigest("search_for_event_occ_#{@eventidsocc}")
    @occevents = Rails.cache.read(really_long_cache_name)
    if (@occevents == nil)
      #puts "**************** No cache found for search query ****************"
      @occevents = Event.includes(:tags).find(@eventidsocc)
      Rails.cache.write(really_long_cache_name, @occevents)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end

    really_long_cache_name = Digest::SHA1.hexdigest("search_for_event_rec_#{@eventidsrec}")
    @recevents = Rails.cache.read(really_long_cache_name)
    if (@recevents == nil)
      #puts "**************** No cache found for search query ****************"
      @recevents = Event.includes(:tags).find(@eventidsrec)
      Rails.cache.write(really_long_cache_name, @recevents)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end


    

    respond_to do |format|

      format.html { render :layout => "mode" }
      format.json { render json: { :pictures =>@venue.pictures ,:occurrences => @occevents.to_json(:include => [:tags,:occurrences]), :recurrences => @recevents.to_json(:include => [:tags,:recurrences]), :venue => @venue.to_json } } 
    end  
  end

def showact
  @act = Act.find(params[:id])
    @occurrences  = []
    @recurrences = []
    @pictures = []
    startTime = Date.today()
    # @occs = @act.events.collect { |event| event.occurrences.select { |occ| occ.start >= startTime }  }.flatten.sort_by { |occ| occ.start }
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_act_#{params[:id]}_#{startTime}")
    @occs =  Rails.cache.read(really_long_cache_name)
    if (@occs == nil)
      #puts "**************** No cache found for search query ****************"
      @occs = @act.events.collect { |event| event.occurrences.select { |occ| occ.start >= startTime }  }.flatten.sort_by { |occ| occ.start }
      Rails.cache.write(really_long_cache_name, @occs)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end
    # @venues = @act.events.collect {|event| event.venue}
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_act_venue_#{params[:id]}_#{startTime}")
    @venues =  Rails.cache.read(really_long_cache_name)
    if (@venues == nil)
      #puts "**************** No cache found for search query ****************"
      @venues = @act.events.collect {|event| event.venue}
      Rails.cache.write(really_long_cache_name, @venues)
      #puts "**************** Cache Set for search Query ****************"
    else
      #puts "**************** Cache FOUND for search query!!! ****************"
    end


    @occs.each do |occ|
      # check if occurrence is instance of a recurrence
      if occ.recurrence_id.nil?
        @occurrences <<  occ
      else
        if @recurrences.index(occ.recurrence).nil?
          @recurrences << occ.recurrence #{:rec => occ.recurrence, :venue => occ.event.venue}
        end
      end
    end
    @recurrences.reject! { |c| c.nil? }
    @occurrences.reject! { |c| c.nil? }
    @act.pictures.each do |pic|
      @pictures << pic
    end

    respond_to do |format|
      format.html { render :layout => "mode" }
      format.json { render json: { :occurrences => @occurrences.to_json(:include => :event), :recurrences => @recurrences.to_json(:include => :event), 
                                   :act => @act, :pictures => @pictures, :embeds => @act.embeds, :tags => @act.tags, :venues =>@venues } } 
    end
end

# def bookmark
   
#     @occurrenceid = Occurrence.find_by_event_id(params[:event_id]).id
#     current_user =  User.find_by_email(params[:email])
#     @bookmark = current_user.main_bookmark_list.bookmarks.build
#     @bookmark.bookmarked_id = @occurrenceid
#     @bookmark.bookmarked_type = "Occurrence"
#     @bookmark.save!
#     respond_to do |format|
#       format.json { render json: { :ids =>@occurrenceid  } } 
#     end
#   end

  def attend
    @occurrenceid =  params[:occurrence_id]
    email = params[:email]
    current_user =  User.find_by_email(email.downcase)
    @attendlist = current_user.attending_list
    if @attendlist.nil?
      @attendlist = BookmarkList.create(:name => "Attending", :description => "Attending", :public => false, :featured => false, :main_bookmarks_list => false, :user_id => current_user.id)
    end
    @bookmark = @attendlist.bookmarks.build
    @bookmark.bookmarked_id = @occurrenceid
    @bookmark.bookmarked_type = "Occurrence"
    @bookmark.save!
    respond_to do |format|
      format.json { render json: { :ids =>@occurrenceid  } } 
    end
  end

  def unattend
    @userid = User.find_by_email(params[:email]).id
    email = params[:email]
    current_user =  User.find_by_email(email.downcase)
    @list = current_user.attending_list
    @event= Occurrence.find(params[:event_id]).event
    @bms= @list.bookmarks.select{ |o| o.bookmarked_type == 'Occurrence' }
    @idd = @event.id
    @bms.each{|bm|
      if bm.bookmarked_id != 1 && bm.bookmarked_id != nil
        occu = Occurrence.find(bm.bookmarked_id)
        eventt = occu.event
        unless eventt.nil?
          if eventt.id == @event.id
            @idd = bm.bookmarked_id
            
            break
          end  
        end
        
      end
      
    }
    @bookmark=@list.bookmarks.find_by_bookmarked_id(@idd)
    @bookmark.destroy
    respond_to do |format|
      format.json { render json: { :ids =>@idd  } } 
    end
  end

  def bookmark
    @event = Event.find(params[:event_id])
    @occurrenceid =  @event.nextOccurrence.id #@event.occurrences.select { |occ| occ.start >= Date.today.to_datetime }.sort_by { |occ| occ.start }.first.id
    email = params[:email]
    current_user =  User.find_by_email(email.downcase)
    @bookmark = current_user.main_bookmark_list.bookmarks.build
    @bookmark.bookmarked_id = @occurrenceid
    @bookmark.bookmarked_type = "Occurrence"
    @bookmark.save!
    respond_to do |format|
      format.json { render json: { :ids =>@occurrenceid  } } 
    end
  end


  
  def unbookmark

    @userid = User.find_by_email(params[:email]).id
    current_user =  User.find_by_email(params[:email])
    @list = current_user.main_bookmark_list
    @event= Occurrence.find(params[:event_id]).event
    @bms= @list.bookmarks.select{ |o| o.bookmarked_type == 'Occurrence' }
    @idd = params[:event_id]
    @bms.each{|bm|
      if bm.bookmarked_id != 1 && bm.bookmarked_id != nil
        occu = Occurrence.find(bm.bookmarked_id)
        eventt = occu.event
        unless eventt.nil?
          if eventt.id == @event.id
            @idd = bm.bookmarked_id
            
            break
          end  
        end
        
      end
      
    }
    @bookmark=@list.bookmarks.find_by_bookmarked_id(@idd)
    @bookmark.destroy
    respond_to do |format|
      format.json { render json: { :ids =>@idd  } } 
    end
  end
  def bookmarkvenue
    current_user =  User.find_by_email(params[:email])
    @bookmark = current_user.main_bookmark_list.bookmarks.build
    @bookmark.bookmarked_id = params[:venueid]
    @bookmark.bookmarked_type = "Venue"
    @bookmark.save!
  end
  def unbookmarkvenue
    @venue = Venue.find(params[:venueid])
    current_user=User.find_by_email(params[:email])
    bookmark = Bookmark.where(:bookmarked_type => 'Venue', :bookmarked_id => @venue.id, :bookmark_list_id => current_user.main_bookmark_list.id).first
    @bookmarkId = bookmark.nil? ? nil : bookmark.id
    @bookmark = Bookmark.find(@bookmarkId)
    @bookmark.destroy
  end
  
  def bookmarkact
    current_user =  User.find_by_email(params[:email])
    @bookmark = current_user.main_bookmark_list.bookmarks.build
    @bookmark.bookmarked_id = params[:actid]
    @bookmark.bookmarked_type = "Act"
    @bookmark.save!



  end
  def followBookmarkList
    list = BookmarkList.first(:conditions => { :id => params[:id] })
    current_user = User.find_by_email(params[:email])
    current_user.followedLists << list  
  end
  def unfollowBookmarkList
    list = BookmarkList.first(:conditions => { :id => params[:id] })
    current_user = User.find_by_email(params[:email])
    current_user.followedLists.delete(list)
  end
  def unbookmarkact
    @act = Act.find(params[:actid])
    current_user=User.find_by_email(params[:email])
    bookmark = Bookmark.where(:bookmarked_type => 'Act', :bookmarked_id => @act.id, :bookmark_list_id => current_user.main_bookmark_list.id).first
    @bookmarkId = bookmark.nil? ? nil : bookmark.id
    @bookmark = Bookmark.find(@bookmarkId)
    @bookmark.destroy
  end

  def getTopLists
    @featuredLists = BookmarkList.where(:featured => true)
    respond_to do |format|
      format.json { render json: { :lists =>@featuredLists  } } 
    end
  end

  def getList
    @bookmarkList = BookmarkList.find(params[:id])
    @occurrences = @bookmarkList.all_bookmarked_events.select{ |o| o.start >= Date.today.to_datetime }
    @es = @occurrences.collect { |occ| occ.event }
    @esinfo =[]
    @es.each{
      |o| 
      @id=o.occurrences.select{|o| o.recurrence_id!=nil}.collect(&:recurrence_id).uniq
      @i = @id.join(',')
      @rcs = []
      if @id.count > 0
        @rcs=Recurrence.where("ID IN (#{@i})")
      end
      
      @ocs=o.occurrences.select{|o| o.recurrence_id==nil}
      acts = o.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }


      @item = {event: o, tags: o.tags, venue: o.venue, recurrences: @rcs, occurrences: @ocs, act: o.acts , actist: act}
      @esinfo << @item
    }
    respond_to do |format|
      format.json { render json: { :event =>@esinfo  } } 
    end
  end

  def newGetList
    tmp ="0"
    tmp1 ="o"
    @listid = params[:id]

    


    query = "SELECT DISTINCT ON (recurrences.id,bookmark_lists.id,acts.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.picture_url AS list_pic, occurrences.end AS end, events.cover_image_url AS cover, venues.phonenumber AS phone, venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor, venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city,  recurrences.start AS rec_start, recurrences.end AS rec_end,recurrences.every_other AS every_other,recurrences.day_of_week AS day_of_week,recurrences.week_of_month AS week_of_month,recurrences.day_of_month AS day_of_month ,occurrences.id AS occurrence_id, recurrences.id AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM venues 
              INNER JOIN events ON venues.id = events.venue_id 
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id 
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id 
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id 
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN recurrences ON events.id = recurrences.event_id 
              INNER JOIN occurrences ON events.id = occurrences.event_id 
              INNER JOIN bookmarks ON occurrences.id =  bookmarks.bookmarked_id 
              INNER JOIN bookmark_lists  ON bookmarks.bookmark_list_id = bookmark_lists.id WHERE bookmarks.bookmarked_id IN ( SELECT bookmarks.bookmarked_id FROM bookmarks 
              FULL JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id 
            WHERE  bookmarks.bookmarked_id IN ( SELECT bookmarks.bookmarked_id FROM bookmarks FULL JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id  WHERE bookmark_lists.id = #{@listid}) AND occurrences.recurrence_id IS NOT NULL 
            UNION
            SELECT DISTINCT ON (events.id,bookmark_lists.id) events.event_url AS url,events.ticket_url AS tix, bookmark_lists.picture_url AS list_pic,occurrences.end AS end,events.cover_image_url AS cover,venues.phonenumber AS phone,venues.id AS v_id, events.price AS price, events.views AS views, events.clicks AS clicks, acts.id AS act_id, acts.name AS actor,venues.address AS address, venues.state AS state,venues.zip AS zip, venues.city AS city, occurrences.start AS rec_start, occurrences.end AS rec_end, #{tmp} AS every_other, #{tmp} AS day_of_week, #{tmp} AS week_of_month, #{tmp} AS day_of_month,occurrences.id AS occurrence_id, #{tmp} AS rec_id, events.description AS description, events.title AS title, venues.name AS venue_name, venues.longitude AS longitude, venues.latitude AS latitude, events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
            FROM venues 
              INNER JOIN events ON venues.id = events.venue_id 
              LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id 
              LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id 
              LEFT OUTER JOIN acts ON acts.id = acts_events.act_id 
              LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
              INNER JOIN occurrences ON events.id = occurrences.event_id 
              INNER JOIN bookmarks ON occurrences.id =  bookmarks.bookmarked_id 
              INNER JOIN bookmark_lists  ON bookmarks.bookmark_list_id = bookmark_lists.id 
            WHERE bookmarks.bookmarked_id IN ( SELECT bookmarks.bookmarked_id FROM bookmarks FULL JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id  WHERE bookmark_lists.id = #{@listid})"
    
    # queryResult = ActiveRecord::Base.connection.select_all(query)
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{query}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      #puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      ##puts "**************** Cache Set for search Query ****************"
    else
      ##puts "**************** Cache FOUND for search query!!! ****************"
    end
    queryResult =[]
    @ids = queryResult
    # ##puts queryResult.uniq
    @eventIDs =  queryResult.collect { |e| e["event_id"] }.uniq
    # ##puts @eventIDs
    esinfo = []
    @eventIDs.each{ |id|
      # ##puts id
      # #puts "SET"
      set =  queryResult.select{ |r| r["event_id"] == id.to_s }
      # #puts set
      # act = set.collect { |s| { :act_name => s["actor"],:act_id => s["act_id"] }.values}.uniq 
      e = Event.find(id)
      acts = e.acts
      act = []
      acts.each{ |a|
        tag_item = []
        tags = a.tags.collect { |tag| tag.name}
        unless a.pictures.first.nil?
          tag_item  << a.name << a.id << tags << a.pictures.first.image.large.url
        else
          tag_item  << a.name << a.id << tags << ""
        end
        
        act << tag_item

      }
      
      
      tps = set.collect { |e|  e["list_pic"].to_i}.uniq
      rec_ids = set.collect { |e| e["rec_id"] }.uniq
      rec = set.collect { |s| { 
        :every_other => s["every_other"],
        :day_of_week => s["day_of_week"],
        :week_of_month => s["week_of_month"], 
        :day_of_month => s["day_of_month"] ,
        :rec_start => s["rec_start"],  # 4
        :rec_end => s["rec_end"]  # 5

        }.values}.uniq 
      # rec = set.collect { |s| { s["every_other"],s["day_of_week"],s["week_of_month"], s["day_of_month"] }}.uniq 
      really_long_cache_name = "event_find_#{id}"
      tags = Rails.cache.read(really_long_cache_name)
      if (tags==nil)
        #puts "**************** No cache found for search event -id  ****************"
        tags  = Event.find(id).tags.collect{ |t| {:id => t.id, :name =>t.name}.values}
        Rails.cache.write(really_long_cache_name, tags)
        #puts "**************** Cache Set for search Query ****************"
      else
        #puts "**************** Cache FOUND for search query - event ids !!! ****************" 
      end
      # #puts tags
     
      s = set.first
      
      item = {
                :act => act, # 0
                :rec => rec , # 1
                :description => s["description"], # 2
                :title => s["title"], # 3
                :occurrence_id => s["occurrence_id"], #4
                :cover => s["cover"] , #5
                :venue_name => s["venue_name"], #6
                :address => s["address"] , #7
                :zip => s["zip"] , #8
                :city => s["city"], #9
                :state => s["state"] , #10
                :phone => s["phone"], # 11
                :lat => s["latitude"], # 12
                :long => s["longitude"], #13
                :venue_id => s["venue_id"], # 14
                :price => s["price"] , #15
                :views => s["views"],  #16
                :clicks => s["clicks"], #17
                :tags  => tags , # 18
                :event_id => s["event_id"], #19
                :start => s["occurrence_start"] , #20
                :end => s["end"], #21
                :user => [], #22
                :tps =>  tps, #23
                :tix => s["tix"],
                :url => s["url"]
              }

      esinfo << item
    }

    ttttmp = esinfo.sort_by{ |hsh| hsh[:start].to_datetime }
    esinfo = ttttmp.drop(@offset).take(@amount)
    esinfo = esinfo.collect{|es| es.values}
    respond_to do |format|
      format.json { render json: { :event =>@esinfo  } } 
    end
  end

  def getchannel
      respond_to do |format|
      
        format.json { render json: {:tags=>Tag.all} }
      
      end
  end

  def update
    @user = User.find_by_email(params[:email])
    @username = @user.username
    @email = @user.email
    @emailuser = User.find_by_email(params[:newemail])
    @usernameuser = User.find_by_username(params[:username])

    if (not @emailuser.nil?) && (not @usernameuser.nil?)
      @newusername = @usernameuser.username
      @neweamil = @emailuser.email

      if @username.eql?(@newusername) && (@email.eql?(@neweamil))
        @user.email=params[:newemail]
        @user.username=params[:username]
        @user.lastname=params[:lastname]
        @user.firstname=params[:firstname]
        @user.save!
        respond_to do |format|
            format.json { render json: {:code=>"1",:message=>"OK" } }
            
        end 
        return
      elsif @username.eql?(@newusername) && (not @email.eql?(@neweamil))
          respond_to do |format|
              format.json { render json: {:code=>"2",:message=>"this is a used email" } }
               
          end
          return  
      elsif (not @username.eql?(@newusername)) && (@email.eql?(@neweamil))
          respond_to do |format|
              format.json { render json: {:code=>"3",:message=>"this is a used username" } }
              
          end
          return
      elsif (not @username.eql?(@newusername)) && (not @email.eql?(@neweamil))
          respond_to do |format|
              format.json { render json: {:code=>"4",:message=>"these are used username and used email" } }
              
          end  
          return
        
      end

      
    elsif (@emailuser.nil?) && (not @usernameuser.nil?)
      @newusername = @usernameuser.username
      if (not @username.eql?(@newusername))
        respond_to do |format|
              format.json { render json: {:code=>"3",:message=>"there is a used username" } }
              
            end
        return
      else
        @user.email=params[:newemail]
        @user.username=params[:username]
        @user.lastname=params[:lastname]
        @user.firstname=params[:firstname]
        @user.save!
        respond_to do |format|
              format.json { render json: {:code=>"1",:message=>"OK" } }
              
            end
        return
      end

    elsif (not @emailuser.nil?) && (@usernameuser.nil?)
      @neweamil = @emailuser.email
      if (not @email.eql?(@neweamil))
        respond_to do |format|
              format.json { render json: {:code=>"2",:message=>"there is a used email" } }
              
            end
        return
      else
        @user.email=params[:newemail]
        @user.username=params[:username]
        @user.lastname=params[:lastname]
        @user.firstname=params[:firstname]
        @user.save!
        respond_to do |format|
              format.json { render json: {:code=>"1",:message=>"OK" } }
              
            end
        return
      end
      
    elsif (@emailuser.nil?) && (@usernameuser.nil?)
      @user.email=params[:newemail]
      @user.username=params[:username]
      @user.lastname=params[:lastname]
      @user.firstname=params[:firstname]
      @user.save!
      respond_to do |format|
            format.json { render json: {:code=>"1",:message=>"OK" } }
            
          end
      return 
    end
  end


end