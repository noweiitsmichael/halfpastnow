class Occurrence < ActiveRecord::Base
  belongs_to :event
  belongs_to :recurrence
  has_many :histories

  # Bi-directional bookmarks association (find a user's bookmarked events, and users who have bookmarked this event)
  belongs_to :bookmarked, :polymorphic => true
  has_many :bookmarks, :as => :bookmarked
  # Allows you to search for users that bookmarked this event by calling "event.bookmarked_by"
  has_many :bookmarked_by, :through => :bookmarks, :source => :user

  validates_presence_of :start
  # validates :end, :presence => true

  def create
    self.day_of_week = (start ? start.to_date.wday : nil)
    super
  end

  def update
    self.day_of_week = (start ? start.to_date.wday : nil)
    super
  end
end
