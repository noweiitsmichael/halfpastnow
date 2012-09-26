class MobileController < ApplicationController
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

	  @user=User.find_by_email(email.downcase)
	  if not @user.nil?
	      puts "Existing email"
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
    @user=User.find_by_email(email.downcase)
    if @user.nil?
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"0" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
        return
      else
        if @user.valid_password?(params[:password])
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
        @user.uid = params[:uid]
        @user.fb_picture = params[:fb_picture]
        @user.username = params[:username]
        @user.password =  Devise.friendly_token[0,20]
        @user.provider = "facebook"
        @user.save!
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: {:code=>"7" } }
            # render json: @events.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        end
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
    pp params
    # @amount = params[:amount] || 20
    # @offset = params[:offset] || 0

    @tags = Tag.all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }
    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = low_price_match = high_price_match = "TRUE"

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

    event_start_date = Date.today().advance(:days => (params[:start_days].to_s.empty? ? 0 : params[:start_days].to_i))
    event_end_date = Date.today().advance(:days => (params[:end_days].to_s.empty? ? 1 : (params[:end_days].to_s == "INFINITY") ? 365000 : params[:end_days].to_i + 1))

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
      pp event_days
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

    puts query
    
    @ids = ActiveRecord::Base.connection.select_all(query)

    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    @event_ids = @ids.collect { |e| e["event_id"] }.uniq
    @venue_ids = @ids.collect { |e| e["venue_id"] }.uniq

    @allOccurrences = Occurrence.includes(:event => :tags, :event => :venue, :event => :occurrences, :event => :recurrences).find(@occurrence_ids, :order => order_by)
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
    @user=User.find_by_email(email)
    @tagss = Tag.all.collect{|t| [t.id,t.name]}
    @tagss = Tag.all.sort_by do |tag|
        tag.id
    end
    if not @user.nil?
      @channels= Channel.where("user_id=?",@user.id)
      
      @tags = @tagss.collect{|t| [t.id,t.name]}
      @bookmarks= Bookmark.where("user_id=?",@user.id)
  	  @occurrenceids= @user.bookmarked_events.collect(&:id)
  	  @eventids = Occurrence.find(@occurrenceids).collect(&:event_id)
  	  @events = Event.includes(:tags, :venue, :recurrences).find(@eventids) 
      @bookmarkedevents =[]
      @events.each { 
        |event| 
        @occurs1 =[]
        @occurs1 << event.occurrences.first
        @reccs1 =[]
        @reccs1 <<  event.recurrences.first
        @item1 = [:event => event, :occurrences => @occurs1 , :recurrences => @reccs1, :venue => event.venue, :tags => event.tags ] 
        @bookmarkedevents << @item1
      }
    end
    # hack to speed up !!!!
    @items =[]
    @occurrences.each { 
      |occ| 
      @event = occ.event
      @occurs =[]
      @occurs << @event.occurrences.first
      @reccs =[]
      @reccs << @event.recurrences.first
      @item = [:event => @event, :occurrences => @occurs , :recurrences => @reccs, :venue => @event.venue, :tags => @event.tags ] 
      @items << @item
    }
    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end

      # format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
      if (params[:email].to_s.empty?)
        # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
        format.json { render json: @items.to_json }
      else 
        format.json { render json: {tag:@tags, user:@user, channels: @channels, :bookmarked =>  @bookmarkedevents,:events=>@items } }
      end

  end

    

  end
  def showVenue
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
    @eventidsocc = @occurrences.collect(&:event_id)
    @eventidsrec = @recurrences.collect(&:event_id)
    @occevents = Event.includes(:tags).find(@eventidsocc)
    @recevents = Event.includes(:tags).find(@eventidsrec)

    respond_to do |format|

      format.html { render :layout => "mode" }
      format.json { render json: { :occurrences => @occevents.to_json(:include => [:tags,:occurrences]), :recurrences => @recevents.to_json(:include => [:tags,:recurrences]), :venue => @venue.to_json } } 
    end  
  end

  def bookmark
    @userid = User.find_by_email(params[:email]).id
    @occurrenceid = Occurrence.find_by_event_id(params[:event_id]).id
    @bookmark = Bookmark.new
    @bookmark.bookmarked_id = @occurrenceid
    @bookmark.bookmarked_type = "Occurrence"
    @bookmark.user_id = @userid
    @bookmark.save!
  end
  
  def unbookmark
    @userid = User.find_by_email(params[:email]).id
    @occurrenceid = Occurrence.find_by_event_id(params[:event_id]).id
    @bookmark = Bookmark.find_by_bookmarked_id(@occurrenceid)
    @bookmark.destroy
  end


end
