class Bookmark < ActiveRecord::Base
  attr_accessible :event_id, :user_id

  belongs_to :user
  has_one :event, :as => :bookmarkable
  has_one :artist, :as => :bookmarkable
  has_one :venue, :as => :bookmarkable
  
end
