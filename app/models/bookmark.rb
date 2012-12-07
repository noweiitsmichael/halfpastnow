class Bookmark < ActiveRecord::Base

  belongs_to :bookmark_list
  belongs_to :bookmarked, :polymorphic => true
  validates_uniqueness_of :bookmarked_id, :scope => [:bookmarked_type, :user_id], :unless =>  Proc.new { |obj| obj.bookmarked_type == "Bookmark List" }

end
