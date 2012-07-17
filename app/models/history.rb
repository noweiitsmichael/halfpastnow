class History < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :occurrence
  validates_uniqueness_of :occurrence_id, :scope => :user_id

end
