class Bookmark < ActiveRecord::Base

  belongs_to :bookmark_list
  belongs_to :bookmarked, :polymorphic => true
  validates_uniqueness_of :bookmarked_id, :scope => [:bookmarked_type, :bookmark_list_id], :unless =>  Proc.new { |obj| obj.bookmarked_type == "Bookmark List" }

end
