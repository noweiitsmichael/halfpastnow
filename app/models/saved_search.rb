class SavedSearch < ActiveRecord::Base
  attr_accessible :search_key, :user_id
  belongs_to :user
  validates :search_key, uniqueness: true
end
