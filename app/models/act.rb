class Act < ActiveRecord::Base
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tags
  has_many :embeds, :dependent => :destroy
  accepts_nested_attributes_for :embeds, :allow_destroy => true
end
