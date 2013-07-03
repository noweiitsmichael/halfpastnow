class UserMailer < ActionMailer::Base
  # default from: "khoa@halfpastnow.com"

  def welcome_email(user)
  	puts "sending email..."
    ActionMailer::Base.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: "halfpastnow.com",
      authentication: "plain",
      enable_starttls_auto: true,
      user_name: "support@halfpastnow.com",
      password: "chimeralabs"
    }
    @user = user
    




    @url  = "http://halfpastnow.com/login"
    mail(:to => @user.email, :subject => "Welcome to halfpastnow!", :from => "Half Past Now <support@halfpastnow.com>")
  end


  def self.find_with(id)
    puts "occurrence.rb"
    
    params = Hash.new
    
   
    channel = Channel.find(id)
      # channel = Channel.find(4)

    params[:option_day] ||= channel.option_day || 0
    params[:start_days] ||= channel.start_days || ""
    params[:end_days] ||= channel.end_days || ""
    params[:start_seconds] ||= channel.start_seconds || ""
    params[:end_seconds] ||= channel.end_seconds || ""
    params[:low_price] ||= channel.low_price || ""
    params[:high_price] ||= channel.high_price || ""
    params[:included_tags] ||= channel.included_tags ? channel.included_tags.split(',') : nil
    params[:excluded_tags] ||= channel.excluded_tags ? channel.excluded_tags.split(',') : nil
    params[:and_tags] ||= channel.and_tags ? channel.and_tags.split(',') : nil
    params[:lat_min] ||= ""
    params[:lat_max] ||= ""
    params[:long_min] ||= ""
    params[:long_max] ||= ""
    params[:offset] ||= 0
    params[:search] ||= ""
    params[:sort] ||= channel.sort || 0
    params[:name] ||= channel.name || ""
    

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end
    
    if(params[:excluded_tags] && params[:excluded_tags].is_a?(String))
      params[:excluded_tags] = params[:excluded_tags].split(",")
    end


    if(params[:and_tags] && params[:and_tags].is_a?(String))
      params[:and_tags] = params[:and_tags].split(",")
    end

    puts "....in find"
    # puts params
    # @tags = Tag.includes(:parentTag, :childTags).all
    # @parentTags = @tags.select{ |tag| tag.parentTag.nil? }

    search_match = occurrence_match = location_match = tag_include_match = tag_exclude_match = tag_and_match = low_price_match = high_price_match = "TRUE"

    @amount = 200
    @offset = 0
    bookmarked = !params[:bookmark_type].to_s.empty?
    isCollection = !params[:collection_type].to_s.empty?

    join_clause = ""
    where_clause = "TRUE"
    join_cache_indicator = 0

    if(bookmarked)

      if(params[:bookmark_type] == "event")

        join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                       INNER JOIN venues ON events.venue_id = venues.id
                       INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id"
        join_cache_indicator = 0

        where_clause = "bookmarks.user_id = #{user_id} AND bookmarks.bookmarked_type = 'Occurrence'"

      elsif(params[:bookmark_type] == "venue")

        join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                       INNER JOIN venues ON events.venue_id = venues.id
                       INNER JOIN bookmarks ON venues.id = bookmarks.bookmarked_id"
        join_cache_indicator = 1

        where_clause = "bookmarks.user_id = #{user_id} AND bookmarks.bookmarked_type = 'Venue'"

      elsif(params[:bookmark_type] == "act")
        
        join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                       INNER JOIN venues ON events.venue_id = venues.id
                       LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                       LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
                       INNER JOIN bookmarks ON acts.id = bookmarks.bookmarked_id"
        join_cache_indicator = 2

        where_clause = "bookmarks.user_id = #{user_id} AND bookmarks.bookmarked_type = 'Act'"

      end
    elsif(isCollection)

      if(params[:collection_type] == "venue")

        join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                       INNER JOIN venues ON events.venue_id = venues.id"
        join_cache_indicator = 3

        where_clause = "venues.id IN (#{params[:collection]})"

      elsif(params[:collection_type] == "act")

        join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                       INNER JOIN venues ON events.venue_id = venues.id
                       LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                       LEFT OUTER JOIN acts ON acts.id = acts_events.act_id"
        join_cache_indicator = 4

        where_clause = "acts.id IN (#{params[:collection]})"

      end
    else
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
        puts "not empty"
        event_end_date = Date.parse(params[:end_date]).advance(:days => 1)
      else
        puts "empty"
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

      if Time.now.hour < 17
        start_date_where = "'#{(Time.now - 2.hours)}'"
      else
        start_date_where = "'#{(Time.now - 3.hours)}'" 
      end


      unless(params[:day].to_s.empty?)
        event_days = params[:day].collect { |day| day.to_i } * ','
        day_check = "#{event_days ? "occurrences.day_of_week IN (#{event_days})" : "TRUE" }"
      end

      occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check} AND #{day_check}" 

      # puts occurrence_match

      # location
      if(params[:lat_min].to_s.empty? || params[:long_min].to_s.empty? || params[:lat_max].to_s.empty? || params[:long_max].to_s.empty?)
        @ZoomDelta = {
                 11 => { :lat => 0.30250564 / 2, :long => 0.20942688 / 2 }, 
                 13 => { :lat => 0.0756264644 / 2, :long => 0.05235672 / 2 }, 
                 14 => { :lat => 0.037808182 / 2, :long => 0.02617836 / 2 }
                }

        # 30.268093,-97.742808
        @lat = params[:lat_center] || 30.268093
        @long = params[:long_center] || -97.742808
        @zoom = params[:zoom] || 11

        # unless params[:location].to_s.empty?
        #   json_object = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + URI::encode(params[:location])).read)
        #   unless (json_object.nil? || json_object["results"].length == 0)

        #     @lat = json_object["results"][0]["geometry"]["location"]["lat"]
        #     @long = json_object["results"][0]["geometry"]["location"]["lng"]
        #     # if the results are of a city, keep it zoomed out aways
        #     if (json_object["results"][0]["address_components"][0]["types"].index("locality").nil?)
        #       @zoom = 14
        #     end
        #   end
        # end

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

      # categories
      tags_cache_included = ""
      tags_cache_excluded = ""

      unless(params[:included_tags].to_s.empty?)
        tags_mush = params[:included_tags] * ','
        tags_cache_included = params[:included_tags] * ','

        tag_include_match = "tags.id IN (#{tags_mush})"
      end

      # tags
      unless(params[:and_tags].to_s.empty?)
        tags_mush = params[:and_tags] * ','
        tags_cache_included = params[:and_tags] * ','

        tag_and_match = "events.id IN (
                      SELECT event_id 
                        FROM events, tags, events_tags 
                        WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush}) 
                        GROUP BY event_id 
                        HAVING COUNT(tag_id) >= #{ params[:and_tags].count }
                    )"
      end
      puts "---------Excluded Tags: ------------"
      puts params[:excluded_tags]
      unless(params[:excluded_tags].to_s.empty?)
        tags_mush = params[:excluded_tags] * ','
        tags_cache_excluded = params[:excluded_tags] * ','
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

      # order_by = "occurrences.start"
      # if(params[:sort].to_s.empty? || params[:sort].to_i == 0)
      #   # order by event score when sorting by popularity
      #   order_by = "CASE events.views 
      #                 WHEN 0 THEN 0
      #                 ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
      #               END DESC"
      # end

      join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                     INNER JOIN venues ON events.venue_id = venues.id
                     LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                     LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id"
        join_cache_indicator = 5

      where_clause = "#{search_match} AND #{occurrence_match} AND #{location_match} AND #{tag_include_match} AND #{tag_exclude_match} AND #{tag_and_match} AND #{low_price_match} AND #{high_price_match}"

    end

    # the big enchilada
    query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id,  events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences 
                #{join_clause}
              WHERE #{where_clause} AND occurrences.start >= #{start_date_where} AND occurrences.deleted IS NOT TRUE
              ORDER BY events.id, occurrences.start LIMIT 1000"

    # puts query
    
    really_long_cache_name = Digest::SHA1.hexdigest("search_for_#{join_cache_indicator}_#{search_match}_#{occurrence_match}_#{location_match}_#{tags_cache_included}_#{tags_cache_excluded}_#{low_price_match}_#{high_price_match}_#{start_date_where}")
    queryResult = Rails.cache.read(really_long_cache_name)
    if (queryResult == nil)
      puts "**************** No cache found for search query ****************"
      queryResult = ActiveRecord::Base.connection.select_all(query)
      Rails.cache.write(really_long_cache_name, queryResult)
      puts "**************** Cache Set for search Query ****************"
    else
      puts "**************** Cache FOUND for search query!!! ****************"
    end
    # queryResult = ActiveRecord::Base.connection.select_all(query) 

    # @event_ids = queryResult.collect { |e| e["event_id"] }.uniq
    # @str_array = @event_ids.collect{|i| i.to_i}.join(',')
    # puts "Qyertttt"
    # puts query
    # queryTag = "SELECT tags.name, t0.event_id AS event_id FROM tags INNER JOIN events_tags t0 ON tags.id = t0.tag_id WHERE t0.event_id IN (#{@str_array})"

    # queryResultTag = ActiveRecord::Base.connection.select_all(queryTag)
    # puts queryResultTag
    # puts queryResultTag.to_json
    
    
    return queryResult
  
  end




  def weekly_email(email)
  	puts "sending email..."
    @user = User.find_by_email(email)
    tgs =[]
    unless @user.nil?
      id = @user.ref
      # check if user has a reference channel
      if (id.nil?) || (id.to_s.eql? "")
        c =  Channel.new 
          # Change to approriate tag ids for Production 
        c.included_tags = "1,134,43,141,29,87,55,192,104"
        c.save!
        @user.ref = c.id.to_s
        @user.save!
      end
      
      id = @user.ref
      channel = Channel.find(id)  
      tgs = channel.included_tags
    else
      tgs = "1,134,43,141,29,87,55,192,104"
    end

    @url  = "http://halfpastnow.com/login"
    event_start = Time.now.advance(:hours => 12)
    event_end = event_start.advance(:days => 1)
    


    start_date_check = "occurrences.start >= '#{Time.now.advance(:hours => 12)}'"
    end_date_check = start_time_check = end_time_check = day_check = "TRUE"
    occurrence_start_time = "((EXTRACT(HOUR FROM occurrences.start) * 3600) + (EXTRACT(MINUTE FROM occurrences.start) * 60))"

    event_start_date = event_end_date = nil
    event_start_date =  Time.now.advance(:hours => 12)
    event_end_date =  Time.now.advance(:days =>7)
    start_date_check = "occurrences.start >= '#{event_start_date}'"
    end_date_check = "occurrences.start <= '#{event_end_date}'"

    event_start_time = 0
    event_end_time =  86400 
    start_time_check = "#{occurrence_start_time} >= #{event_start_time}"
    end_time_check = "#{occurrence_start_time} <= #{event_end_time}"
      


    occurrence_match = "#{start_date_check} AND #{end_date_check} AND #{start_time_check} AND #{end_time_check}"
    
    tags_mush = tgs.split(",").join(",")
    tag_include_match = "TRUE"
    if tgs.size >0
      tag_include_match = "tags.id IN (#{tags_mush})"  
    end
    
    where_clause = "#{occurrence_match} AND #{tag_include_match}"

    order_by = "CASE events.views 
                  WHEN 0 THEN 0
                  ELSE (LEAST((events.clicks*1.0)/(events.views),1) + 1.96*1.96/(2*events.views) - 1.96 * SQRT((LEAST((events.clicks*1.0)/(events.views),1)*(1-LEAST((events.clicks*1.0)/(events.views),1))+1.96*1.96/(4*events.views))/events.views))/(1+1.96*1.96/events.views)
                  END DESC"

    query ="
    SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id FROM occurrences 
    INNER JOIN events ON occurrences.event_id = events.id
    INNER JOIN venues ON events.venue_id = venues.id
    LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
    LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
    WHERE #{where_clause} AND occurrences.deleted IS NOT TRUE
              ORDER BY events.id, occurrences.start LIMIT 1000"
    queryResult = ActiveRecord::Base.connection.select_all(query)
    puts queryResult

    @ids =  queryResult.collect { |e| e["occurrence_id"].to_i }.uniq
    @occurrences = Occurrence.includes(:event => :tags).find(@ids, :order => order_by)
    @ids = @occurrences.collect{|o| o.id}
    @ids=@ids[0,5]
    puts "6 events: "
    puts @ids
    user=@user
    count = 0;
    @bookmarkedEvents =[]
    @bookmarkedEventstmp =[]
    
    
    # Channnels
    channels = []
    unless user.nil?
      channelids =  user.channels.collect{|c| c.id}
    end
    # Get events from channels
    bmids = []
    channelids.each{
      |id|
      puts "find_with output: "
      es =  self.class.find_with(id)
      es.each{
        |ev|
        bmids << ev["occurrence_id"]
        if count == 2
          break
        else
          count = count + 1
        end
      }
      if count == 2
        break
      end
    }

    puts "bmids hehre"
    puts bmids


    if bmids.size > 0
      @bookmarkedEvents =  Occurrence.find(bmids)
    end

    unless user.nil?
      @bookmarkedEventstmp=user.bookmarked_events.select{|o| o.start>Time.now.advance(:hours => 12)}.uniq.sort! { |a,b| a.start <=> b.start }
      
      if @bookmarkedEvents.size < 3 && @bookmarkedEvents.size > 0
         @bookmarkedEventstmp.sort_by{|user| (user.recurrence_id==nil) ? 1 : 0 }
         @bookmarkedEvents =  @bookmarkedEvents << @bookmarkedEvents[0, 3 -  @bookmarkedEvents.size]
         @bookmarkedEvents = bookmarkedEvents.flatten

      end
    
    end
    puts "Bookamark ebents"
    puts @bookmarkedEvents



    @email = email
    # Find 3 upcomming Top Pick event
    query = "SELECT a.title, a.clicks, a.views, a.name, a.occurrence_id, a.recurrence_id, a.start, a.id, a.event_id, a.venue_id, a.cover_image_url, a.picture_url
        FROM
        ((SELECT DISTINCT ON (events.title) events.title, events.clicks, occurrences.id AS occurrence_id, events.views, venues.name, occurrences.recurrence_id AS recurrence_id, occurrences.start, occurrences.id, occurrences.event_id, events.venue_id, events.cover_image_url, bookmark_lists.picture_url
          FROM bookmarks 
          LEFT JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id
          LEFT JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
          LEFT JOIN events ON occurrences.event_id = events.id
          LEFT JOIN venues ON events.venue_id = venues.id
                  LEFT JOIN recurrences ON events.id = recurrences.event_id
                  WHERE bookmarks.bookmarked_type = 'Occurrence' AND bookmark_lists.featured IS TRUE AND occurrences.recurrence_id IS NOT NULL)
                UNION 
                (SELECT DISTINCT ON (events.title) events.title, events.clicks, occurrences.id AS occurrence_id, events.views, venues.name, occurrences.recurrence_id AS recurrence_id, occurrences.start, occurrences.id, occurrences.event_id, events.venue_id, events.cover_image_url, bookmark_lists.picture_url
          FROM bookmarks 
          LEFT JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id
          LEFT JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
          LEFT JOIN events ON occurrences.event_id = events.id
          LEFT JOIN venues ON events.venue_id = venues.id
                  LEFT JOIN recurrences ON events.id = recurrences.event_id
                  WHERE bookmarks.bookmarked_type = 'Occurrence' AND occurrences.start >= '#{Date.today().advance(:hours => 12)}' AND bookmark_lists.featured IS TRUE AND occurrences.recurrence_id IS NULL AND occurrences.start < now() + INTERVAL '8 days')) a
        "
    # Currently only sorting by clicks, might want to switch to popularity at some point but whatever, not that important.

    @result = ActiveRecord::Base.connection.select_all(query)

    # pp "************ RESULTS FROM QUERY ***************"
    # y @result
    # TODO: THIS CAN BE MADE MORE EFFICIENT
    @result.each do |r|
      unless r["recurrence_id"].blank?
        puts r["title"]
        upcoming = Occurrence.find(r["id"]).event.nextOccurrence
        pp upcoming
        unless upcoming.nil?
          r["id"] = upcoming.id
          r["start"] = upcoming.start
        end
      end
    end
    @tpids =  @result.collect { |e| e["id"].to_i }.uniq
    puts "Is there a Z"
    puts @tpids
    @tpoccurrences = Occurrence.includes(:event => :tags).find(@tpids, :order => order_by)
    @tpoccurrences = @tpoccurrences[0,3]

    # ActionMailer::Base.smtp_settings = {
    #   address: "smtp.gmail.com",
    #   port: 587,
    #   domain: "halfpastnow.com",
    #   authentication: "plain",
    #   enable_starttls_auto: true,
    #   user_name: "weekly@halfpastnow.com",
    #   password: "chimeralabs",
    #   :from => "Half Past Now NewsLetter <weekly@halfpastnow.com>"
    # }

    ActionMailer::Base.smtp_settings = {
    :address =>        'smtp.mandrillapp.com',
    :port =>           '587',
    :domain =>         'halfpastnow.com',
    :authentication => 'plain',
    :enable_starttls_auto => true,
    :user_name =>      ENV['MANDRILL_USERNAME'],
    :password =>       ENV['MANDRILL_APIKEY'],
    :from =>           "Half Past Now Newsletter <weekly@halfpastnow.com>"
}
ActionMailer::Base.delivery_method = :smtp

  #   mail(:to => user.email, :subject => "This week in halfpastnow!" , user_name: "support@halfpastnow.com", password: "chimeralabs", address: "http://radiant-flower-7307.herokuapp.com/")
    # mail(:to => email, :subject => "This week in Austin - your event itinerary",:from => "Half Past Now Newsletter <weekly@halfpastnow.com>" )
  
   end
  
end
