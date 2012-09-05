class Venue < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :events, :dependent => :destroy
  has_many :raw_venues

  # So we can assign to admin:
  belongs_to :user

  # Bi-directional bookmarks association (find a user's bookmarked venues, and users who have bookmarked this venue)
  has_many :bookmarks, :as => :bookmarked
  belongs_to :bookmarked, :polymorphic => true
  # Allows you to search for users that bookmarked this venue by calling "venue.bookmarked_by"
  has_many :bookmarked_by, :through => :bookmarks, :source => :user

  accepts_nested_attributes_for :events, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
  
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
end
