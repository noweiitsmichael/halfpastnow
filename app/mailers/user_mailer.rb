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
    event_start = Time.now
    event_end = event_start.advance(:days => 1)
    


    start_date_check = "occurrences.start >= '#{Date.today()}'"
    end_date_check = start_time_check = end_time_check = day_check = "TRUE"
    occurrence_start_time = "((EXTRACT(HOUR FROM occurrences.start) * 3600) + (EXTRACT(MINUTE FROM occurrences.start) * 60))"

    event_start_date = event_end_date = nil
    event_start_date = Date.today()
    event_end_date = Date.today().advance(:days =>7)
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
    @bookmarkedEvents =[]
    unless user.nil?
       @bookmarkedEvents=user.bookmarked_events.select{|o| o.start>Time.now}.uniq.sort! { |a,b| a.start <=> b.start }
      if @bookmarkedEvents.size > 3
        @bookmarkedEvents = @bookmarkedEvents[0,3]
      end 
    else  
       @bookmarkedEvents =[]
    end
   

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
                  WHERE bookmarks.bookmarked_type = 'Occurrence' AND occurrences.start >= '#{Date.today()}' AND bookmark_lists.featured IS TRUE AND occurrences.recurrence_id IS NULL AND occurrences.start < now() + INTERVAL '8 days')) a
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
    :from =>           "Half Past Now NewsLetter <weekly@halfpastnow.com>"
}
ActionMailer::Base.delivery_method = :smtp

  #   mail(:to => user.email, :subject => "This week in halfpastnow!" , user_name: "support@halfpastnow.com", password: "chimeralabs", address: "http://radiant-flower-7307.herokuapp.com/")
    mail(:to => email, :subject => "This week at Half Past Now",:from => "Half Past Now NewsLetter <weekly@halfpastnow.com>" )
  
   end
  
end
