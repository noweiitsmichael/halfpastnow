module VenuesHelper
  def to_ordinal(num)
    return num.to_s + @ordinal[num%10]
  end

  def display_datetime(datetime)
  	return datetime ? datetime.to_time.strftime("%a %b %-d, %Y at %-I:%M %P") : nil
  end

  def hidden_datetime(datetime)
  	return datetime ? datetime.to_time.strftime("%Y-%m-%dT%H:%M:%S") : nil
  end

  def display_time(datetime)
  	return datetime ? datetime.to_time.strftime("%-I:%M %P") : nil
  end

  def display_date(datetime)
    return datetime ? datetime.to_time.strftime("%a %b %-d, %Y") : nil
  end


  def hidden_date(datetime)
    return datetime ? datetime.to_time.strftime("%Y-%m-%d") : nil
  end
end
