class Tag < ActiveRecord::Base
  has_and_belongs_to_many :events
  has_and_belongs_to_many :venues
  has_and_belongs_to_many :acts
  has_many :childTags, :class_name => "Tag", :foreign_key => "parent_tag_id"
  belongs_to :parentTag, :class_name => "Tag", :foreign_key => "parent_tag_id"
end
