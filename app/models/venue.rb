class Venue < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name,use: :slugged
  geocoded_by :name
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :neighborhoods
  has_many :events, :dependent => :destroy
  has_many :raw_venues
  has_many :pictures, :as => :pictureable, :dependent => :destroy
  has_many :embeds, :as => :embedable, :dependent => :destroy

  attr_accessor :image, :remote_image_url, :venuesCooked
  cattr_accessor :venuesCooked
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => proc {|attributes| attributes['image'].blank? && attributes['remote_image_url'].blank?  }
  # So we can assign to admin:
  belongs_to :user

  # Bi-directional bookmarks association (find a user's bookmarked venues, and users who have bookmarked this venue)
  has_many :bookmarks, :as => :bookmarked, :dependent => :destroy 
  belongs_to :bookmarked, :polymorphic => true
  # Allows you to search for users that bookmarked this venue by calling "venue.bookmarked_by"
  # has_many :bookmarked_by, :through => :bookmarks, :source => :user

  accepts_nested_attributes_for :events, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :embeds, :allow_destroy => true
  
  validates_presence_of :name #, :address, :city
  #validates :state, :presence => true, :length => { :minimum => 2, :maximum => 2, :message => "Please use the state postal code (eg. TX for Texas)"}
  #validates :zip, :length => { :minimum => 5, :maximum => 5}, :numericality => true, :presence => true,  ##removed b/c facebook 

  def raw_events (params = {})
  	return (self.raw_venues.collect do |raw_venue| 
  		raw_venue.raw_events.select do |raw_event| 
  			raw_event.submitted == params[:submitted] && raw_event.deleted == params[:deleted] 
  		end
  	end).flatten.compact
  end

  def deleted_raw_events (params = {})
    return (self.raw_venues.collect do |raw_venue| 
      raw_venue.raw_events.select do |raw_event| 
        raw_event.submitted == params[:submitted] && raw_event.deleted == true && raw_event.start > Time.now 
      end
    end).flatten.compact
  end

  def completedness
    total_elements = 9
    complete_elements = 0
    unless(self.description.to_s.empty?)
      complete_elements += 1
    end
    unless(self.phonenumber.nil?)
      complete_elements += 1
    end
    unless(self.address.nil?)
      complete_elements += 5
    end
    unless(self.url.nil?)
      complete_elements += 1
    end
    unless(self.pictures.empty?)
      complete_elements += 1
    end
    return complete_elements.to_f / total_elements.to_f
  end
end
