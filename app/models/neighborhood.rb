class Neighborhood < ActiveRecord::Base
  # attr_accessible :title, :body
  has_and_belongs_to_many :venues
  has_many :events, :through => :venues
  has_many :occurrences, :through => :events
end
