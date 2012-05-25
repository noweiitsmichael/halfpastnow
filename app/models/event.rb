class Event < ActiveRecord::Base
  belongs_to :venue
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :recurrences, :dependent => :destroy
  has_many :occurrences, :dependent => :destroy
  accepts_nested_attributes_for :occurrences, :allow_destroy => true
  accepts_nested_attributes_for :recurrences, :allow_destroy => true
  accepts_nested_attributes_for :venue
  
  validates_presence_of :venue_id, :title
  # define_index do
  #       indexes title, :sortable => true
  #       indexes description
  #       indexes venue.name
  # end

  def matches? (search)
    if (search.nil? || search == "")
      return true
    end
    search = search.gsub(/[^0-9a-z ]/i, '').downcase
    searches = search.split(' ')
    
    searches.each do |word|
      word += ' '
      title = self.title.nil? ? ' ' : self.title.gsub(/[^0-9a-z ]/i, '').downcase + ' '
      description = self.description.nil? ? ' ' : self.description.gsub(/[^0-9a-z ]/i, '').downcase + ' '
      venue_name = self.venue.name.nil? ? ' ' : self.venue.name.gsub(/[^0-9a-z ]/i, '').downcase + ' '
      if !(title.include?(word) || description.include?(word) || venue_name.include?(word))
        return false
      end
    end

    return true
  end

  def score
    if self.views == 0
      return 0
    end
    n = self.views
    p = self.clicks
    z = 1.96
    phat = [1.0*p/n,1].min
    # puts "n: " + n.to_s
    # puts "p: " + p.to_s
    # puts "z: " + z.to_s
    # puts "phat: " + phat.to_s
    puts (phat*(1-phat)+z*z/(4*n))/n
    return (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)
  end

end
