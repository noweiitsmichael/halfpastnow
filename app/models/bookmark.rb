class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :bookmark_list
  belongs_to :bookmarked, :polymorphic => true
  validates_uniqueness_of :bookmarked_id, :scope => [:bookmarked_type, :bookmark_list_id], :unless =>  Proc.new { |obj| obj.bookmarked_type == "Bookmark List" }

 def bookmarked_event
		if !Occurrence.exists?(self.bookmarked_id)
			return nil
		else

			## Cache Query
		    o = Rails.cache.read("occurrence_find_#{self.bookmarked_id}")
		    if (o == nil)
		      o = Occurrence.find(self.bookmarked_id)
		      Rails.cache.write("occurrence_find_#{self.bookmarked_id}", o, :expires_in => 1.day)
		    end
		    ## original query:
			# o = Occurrence.find(self.bookmarked_id)
	        ## End Cache Query

			
			if o.start >= Date.today.to_datetime && !o.deleted
				return o
			else
				# return o.event.nextOccurrence
				unless o.event.nil?
					return o.event.nextOccurrence
				else	
					return nil
				end
				
			end
		end
	end
end
