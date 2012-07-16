class Bookmark < ActiveRecord::Base
  attr_accessible :event_id, :user_id, :bookmarked_id, :bookmarked_type

  belongs_to :user
  belongs_to :bookmarked, :polymorphic => true

end
