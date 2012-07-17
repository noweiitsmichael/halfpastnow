class Channel < ActiveRecord::Base
  attr_accessible :day_of_week, :end, :price, :start
end
