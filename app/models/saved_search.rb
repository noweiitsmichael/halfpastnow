class SavedSearch < ActiveRecord::Base
  attr_accessible :search_key, :user_id
  belongs_to :user
end
