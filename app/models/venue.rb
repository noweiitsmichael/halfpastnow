class Venue < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :events, :dependent => :destroy
  has_many :raw_venues
  belongs_to :bookmarkable, :polymorphic => true
  accepts_nested_attributes_for :events, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
  
  validates_presence_of :name, :address, :city
  validates :state, :presence => true, :length => { :minimum => 2, :maximum => 2, :message => "Please use the state postal code (eg. TX for Texas)"}
  validates :zip, :presence => true, :length => { :minimum => 5, :maximum => 5}, :numericality => true

  def raw_events (params = {})

  	return (self.raw_venues.collect do |raw_venue| 
  		raw_venue.raw_events.select do |raw_event| 
  			raw_event.submitted == params[:submitted] && raw_event.deleted == params[:deleted] 
  		end
  	end).flatten.compact
  end
end
