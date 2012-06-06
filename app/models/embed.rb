class Embed < ActiveRecord::Base
  belongs_to :act
  attr_accessible :source
end
