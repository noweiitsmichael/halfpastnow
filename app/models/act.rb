class Act < ActiveRecord::Base
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tags
  has_many :embeds, :dependent => :destroy

  # So we can assign to admin:
  belongs_to :user

  # Bi-directional bookmarks association (find a user's bookmarked performers, and users who have bookmarked this performer)
  belongs_to :bookmarked, :polymorphic => true
  has_many :bookmarks, :as => :bookmarked
  # Allows you to search for users that bookmarked this artist by calling "act.bookmarked_by"
  has_many :bookmarked_by, :through => :bookmarks, :source => :user
  
  accepts_nested_attributes_for :embeds, :allow_destroy => true
end
