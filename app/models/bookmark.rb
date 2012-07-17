class Bookmark < ActiveRecord::Base
  attr_accessible :event_id, :user_id, :bookmarked_id, :bookmarked_type

  belongs_to :user
  belongs_to :bookmarked, :polymorphic => true
  validates_uniqueness_of :bookmarked_id, :scope => [:bookmarked_type, :user_id]

end
