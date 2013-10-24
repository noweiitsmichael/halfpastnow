class Event < ActiveRecord::Base
  belongs_to :venue
  belongs_to :user
  
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :acts


  has_many :recurrences, :dependent => :destroy
  has_many :occurrences, :dependent => :destroy
  has_many :bookmarks, :through => :occurrences
  has_many :pictures, :as => :pictureable, :dependent => :destroy
  has_many :embeds, :as => :embedable, :dependent => :destroy

  accepts_nested_attributes_for :occurrences, :allow_destroy => true
  accepts_nested_attributes_for :recurrences, :allow_destroy => true
  accepts_nested_attributes_for :venue
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => proc {|attributes| attributes['image'].blank? && attributes['remote_image_url'].blank?  }
  accepts_nested_attributes_for :embeds, :allow_destroy => true

  attr_accessor :image, :remote_image_url
  
  validates_presence_of :venue_id
  validates_presence_of :title, :message => "Please input event title"

  after_create :clear_cache
  # after_create :completedness
  # after_save :completedness

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

  searchable do
    text :title, :boost => 5
    text :description
    text :venue_name, :boost => 4 do
      venue.name if venue.present?
    end
    text :venue_description do
      venue.description if venue.present?
    end
    #text :artists do
    #  acts.map(&:name)
    #end
    #string :tag_names, multiple: true, stored: true do
    #  tags.map(&:name)
    #end
    #string :price_search do
    #  price.downcase.gsub(/^(an?|the)\b/, '')
    #end
    integer :price
  end

  def price_search
    #price.strftime("%B %Y")
  end


  def score
    if self.views == 0
      return 0
    end
    n = self.views
    p = self.clicks
    z = 1.96
    phat = [1.0*p/n,1].min
    event_score = (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)

    tags_weights = self.tags.collect(&:weight)
    acts_weights = self.acts.collect(&:weight)
    tags_weight = tags_weights.empty? ? 1 : tags_weights.sum/tags_weights.size.to_f
    acts_weight = acts_weights.empty? ? 1 : acts_weights.max

    event_score =  event_score * self.weight * self.venue.weight * tags_weight * acts_weight
    return event_score
  end

  def completedness
    total_elements = 8
    complete_elements = 0
    unless(self.description.to_s.empty?)
      complete_elements += 1
    end
    unless(self.cover_image.nil?)
      complete_elements += 5
    end
    unless(self.tags.empty?)
      complete_elements += 1
    end
    unless(self.pictures.empty?)
      complete_elements += 1
    end

    # puts "*******calculating completedness*************"
    # puts complete_elements.to_f / total_elements.to_f

    return complete_elements.to_f / total_elements.to_f
  end

  def nextOccurrence
    if self.occurrences.length == 0
      return nil
    end
    #  # wtf is this
    occurrenceTime = DateTime.new(3000,1,1)
    occurrence = nil

    self.occurrences.each do |occ|
      if occ.start && (occ.start > Time.now) && (occ.start < occurrenceTime)
        occurrence = occ
        occurrenceTime = occ.start
      end
    end

    # occurrenceTime = DateTime.new(3000,1,1)
    # occurrence = nil
    # self.occurrences.each do |occ|
    #   # if occ is in the future and less than the previously found soonest occurrence
    #   if (occ.start > Time.now) && (occ.start < occurrenceTime)
    #     occurrence = occ
    #   end
    # end
    
    return occurrence
  end

  def clear_cache
    puts "-----Resetting cache....."
    Rails.cache.clear
  end


end
