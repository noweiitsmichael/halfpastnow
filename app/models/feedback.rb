class Feedback < ActiveRecord::Base
  attr_accessible :description, :status, :subject, :type, :user_id
end
