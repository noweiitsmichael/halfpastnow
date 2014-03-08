class VenueNeighbourhoodFetch < ActiveRecord::Base
  attr_accessible :count, :start_date
  validates_uniqueness_of :start_date
end
