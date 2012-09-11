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

  def FBlogin

    @tags = Tag.all
    @parentTags = @tags.select{ |tag| tag.parentTag.nil? }

    # pp params
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
      tags_mush = params[:included_tags].collect { |str| str.to_i } * ','
      tag_include_match = "events.id IN (
                    SELECT event_id 
                      FROM events, tags, events_tags 
                      WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
                      GROUP BY event_id 
                      HAVING COUNT(tag_id) >= #{ params[:included_tags].count }
                  )"
    end

    unless(params[:excluded_tags].to_s.empty?)
      tags_mush = params[:excluded_tags].collect { |str| str.to_i } * ','
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

    

    if @event_ids.count > 0
      ActiveRecord::Base.connection.update("UPDATE events
        SET views = views + 1
        WHERE id IN (#{@event_ids * ','})")

      ActiveRecord::Base.connection.update("UPDATE venues
        SET views = views + 1
        WHERE id IN (#{@venue_ids * ','})")
    end

    uid = params[:uid]
    @user=User.find_by_uid(uid)
   	@channels= Channel.where("user_id=?",@user.id)
    @tagss = Tag.all.collect{|t| [t.id,t.name]}
    @tagss = Tag.all.sort_by do |tag|
        tag.id
      end
    @tags = @tagss.collect{|t| [t.id,t.name]}
    @bookmarks= Bookmark.where("user_id=?",@user.id)
	@occurrenceids= @user.bookmarked_events.collect(&:id)
	@eventids = Occurrence.find(@occurrenceids).collect(&:event_id)
	@events = Event.includes(:tags, :venue, :recurrences).find(@eventids) 

    respond_to do |format|
      format.html do
        unless (params[:ajax].to_s.empty?)
          render :partial => "combo", :locals => { :occurrences => @occurrences, :occurringTags => @occurringTags, :parentTags => @parentTags }
        end
      end
      # format.json { render json: @occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) }
      format.json { render json: {code:"3",tag:@tags, user:@user, channels: @channels, :bookmarked =>  @events.to_json(:include => [:venue, :recurrences, :occurrences, :tags]),:events=>@occurrences.collect { |occ| occ.event }.to_json(:include => [:occurrences, :venue, :recurrences, :tags]) } } 
     
    end

    

  end


end
