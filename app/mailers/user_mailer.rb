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
    query ="
    SELECT occurrences.id AS occurrence_id FROM occurrences 
    INNER JOIN events ON occurrences.event_id = events.id
    INNER JOIN venues ON events.venue_id = venues.id
    LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
    LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id 
    WHERE TRUE AND occurrences.start >= '#{event_start}'  AND occurrences.start <= '#{event_end}'"
    queryResult = ActiveRecord::Base.connection.select_all(query)
    puts queryResult

    @ids =  queryResult.collect { |e| e["occurrence_id"].to_i }.uniq
    
    @ids = @ids[0,5]
    puts "6 events: "
    puts @ids
    mail(:to => user.email, :subject => "This week in halfpastnow!")
  end
  
end
