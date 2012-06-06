class Act < ActiveRecord::Base
  belongs_to :event
  has_many :embeds, :dependent => :destroy
  attr_accessible :description, :name
end
