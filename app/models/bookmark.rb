class Bookmark < ActiveRecord::Base
  attr_accessible :event_id, :user_id

  has_one :event
  
end
