class UserMailer < ActionMailer::Base
  default from: "support@halfpastnow.com"

  def welcome_email(user)
  	puts "sending email..."
    @user = user
    @url  = "http://halfpastnow.com/login"
    mail(:to => user.email, :subject => "Welcome to halfpastnow!")
  end
  def weekly_email(user)
  	puts "sending email..."
    @user = user
    @url  = "http://halfpastnow.com/login"
    event_start = Time.now
    event_end = event_start.advance(:days => 1)
    id = user.ref
    channel = Channel.find(id)


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

    tags_mush = channel.included_tags.split(",").join(",")
    tag_include_match = "tags.id IN (#{tags_mush})"
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
    @bookmarkedEvents=user.bookmarked_events.select{|o| o.start>Time.now}.uniq.sort! { |a,b| a.start <=> b.start }
    if @bookmarked_events.count > 3
      @bookmarked_events = @bookmarked_events[0,2]
    end



    mail(:to => user.email, :subject => "This week in halfpastnow!" , :from => "weekly@halfpastnow.com")
  end
  
end
