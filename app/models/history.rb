class History < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :occurrence
end
