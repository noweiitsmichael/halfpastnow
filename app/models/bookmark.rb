class Bookmark < ActiveRecord::Base

  belongs_to :bookmark_list
  belongs_to :bookmarked, :polymorphic => true
  validates_uniqueness_of :bookmarked_id, :scope => [:bookmarked_type, :bookmark_list_id], :unless =>  Proc.new { |obj| obj.bookmarked_type == "Bookmark List" }

  
  def bookmarked_event
		if !Occurrence.exists?(self.bookmarked_id)
			return nil
		else
			o = Occurrence.find(self.bookmarked_id)
			if o.start >= Date.today.to_datetime && !o.deleted
				return o
			else
				return o.event.nextOccurrence
			end
		end
	end
end
