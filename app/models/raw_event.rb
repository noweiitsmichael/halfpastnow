class RawEvent < ActiveRecord::Base
	belongs_to :raw_venue, :class_name => "RawVenue"

	has_many :embeds, :as => :embedable, :dependent => :destroy
	accepts_nested_attributes_for :embeds, :allow_destroy => true
end
