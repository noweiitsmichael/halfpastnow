class RawEvent < ActiveRecord::Base
	belongs_to :raw_venue, :class_name => "RawVenue"

	has_many :embeds, :as => :embedable, :dependent => :destroy
	has_many :pictures, :as => :pictureable, :dependent => :destroy
	accepts_nested_attributes_for :embeds, :allow_destroy => true
end
