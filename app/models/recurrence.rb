require 'pp'

class Interval
  DAY = 0
  WEEK = 1
  MONTH = 2
end

class Recurrence < ActiveRecord::Base
  has_many :occurrences, :dependent => :destroy
  belongs_to :event

  validates_presence_of :start

  def create
    puts "generating occurrences (create)"
    if (self.occurrences.length == 0)
      puts "if"
      self.gen_occurrences
    end
    super
  end

  def update
    puts "generating occurrences (update)"
    if (self.occurrences.length == 0)
      puts "if"
      self.gen_occurrences
    end
    super
  end

  def next_occurrence(time)
    until_time = (range_end && range_end.to_time < Time.now.advance(:years => 1)) ? range_end.to_time : Time.now.advance(:years => 1)
    if(day_of_week && week_of_month)
      time_next_month = time.advance(:months => 1)
      time = time_next_month.beginning_of_month.advance(:weeks => week_of_month, :days => (day_of_week - time_next_month.beginning_of_month.wday)%7)
    elsif(day_of_week)
      time = time.advance(:weeks => (every_other || 0) + 1)
    elsif(day_of_month)
      mday = time.mday
      begin
      	time = time.advance(:months => (every_other || 0) + 1)
      	if(time.mday != mday && Time.days_in_month(time.month) >= mday)
      	  time.advance(:days => (mday - time.mday))
      	end
      	if time.to_date > until_time.to_date
      	  return nil
      	end
      end until time.mday == mday
    else
      time = time.advance(:days => (every_other || 0) + 1)
    end
    return time
  end
  

  def gen_occurrences(number_of_occurrences = -1)
    occurrences_exist = (self.occurrences.size > 0)
    puts "do occurrences exist? " + (occurrences_exist ? "YES" : "NO")
    until_time = (range_end && range_end.to_time < Time.now.advance(:years => 1)) ? range_end.to_time : Time.now.advance(:years => 1)
    counter_time = occurrences_exist ? self.occurrences.last(:order => "start").start.to_date.to_time : ((range_start && range_start.to_date.to_time > Date.today.to_time) ? range_start.to_date.to_time : Date.today.to_time)
    puts "original time: " + counter_time.to_s
    puts "until time: " + until_time.to_s

    if(occurrences_exist)
      counter_time = next_occurrence(counter_time)
      if !counter_time
        return false
      end
    else
      if(day_of_week && week_of_month)
      	puts "monthly (week)"
        occurrence_this_month = counter_time.beginning_of_month.advance(:weeks => week_of_month, :days => (day_of_week - counter_time.beginning_of_month.wday)%7)
      	counter_time_next_month = counter_time.advance(:months => 1)
      	occurrence_next_month = counter_time_next_month.beginning_of_month.advance(:weeks => week_of_month, :days => (day_of_week - counter_time_next_month.beginning_of_month.wday)%7)
      	counter_time = (counter_time.mday > occurrence_this_month.mday) ? occurrence_next_month : occurrence_this_month
      elsif(day_of_week)
        puts "weekly"
        counter_time = counter_time.advance(:days => (day_of_week - counter_time.wday)%7)
      elsif(day_of_month)
        puts "monthly (day)"
        first_loop = true
        begin
      	  if(day_of_month > Time.days_in_month(counter_time.month) || (first_loop && day_of_month < counter_time.mday))
      	    counter_time = counter_time.advance(:months => 1)
      	  else
      	    counter_time = counter_time.advance(:days => (day_of_month - counter_time.mday))
      	  end
          first_loop = false
          puts "monthly (day) counter at " + counter_time.to_s
        end until(counter_time.mday == day_of_month || counter_time.to_date > until_time.to_date)
      else
        puts "daily"
      end
    end
    
    puts "first counter time: " + counter_time.to_s
    counter_occurrences = 0
    while (counter_time.to_date <= until_time.to_date && (!(number_of_occurrences >= 0) || counter_occurrences < number_of_occurrences))
      #build occurrence
      start_datetime = counter_time.advance(:hours => self.start.to_time.hour, :minutes => self.start.to_time.min).to_datetime
      if(self.end)
        event_length = self.end - self.start
        end_datetime = start_datetime.to_time.advance(:hours => event_length.to_i/3600, :minutes => (event_length.to_i%3600)/60).to_datetime
        occurrences.build(:start => start_datetime, :end => end_datetime, :event_id => self.event_id, :day_of_week => start_datetime.to_date.wday)
      else 
        occurrences.build(:start => start_datetime, :event_id => self.event_id, :day_of_week => start_datetime.to_date.wday)
      end
      #find next occurrence time
      counter_time = next_occurrence(counter_time)
      if !counter_time
        break
      end
      
      counter_occurrences += 1
    end
    
    # self.save

    return counter_occurrences > 0
  end
end