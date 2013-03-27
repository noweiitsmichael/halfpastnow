class BookmarkList < ActiveRecord::Base
	has_and_belongs_to_many :followingUsers, :class_name => "User", :join_table => "bookmark_lists_users"
	belongs_to :user
	# Bi-directional bookmarks association (find a user's bookmarked performers, and users who have bookmarked this performer)
	belongs_to :bookmarked, :polymorphic => true
	# has_many :bookmarks, :as => :bookmarked, :dependent => :destroy
	has_many :bookmarks, :dependent => :destroy
	has_many :bookmarked_venues, :through => :bookmarks, :source => :bookmarked, :source_type => "Venue"
    has_many :bookmarked_events, :through => :bookmarks, :source => :bookmarked, :source_type => "Occurrence"
    has_many :bookmarked_acts, :through => :bookmarks, :source => :bookmarked, :source_type => "Act"
	# Allows you to search for users that bookmarked this artist by calling "act.bookmarked_by"
	# has_many :followed_by, :through => :bookmarks, :source => :user

	mount_uploader :picture, PictureUploader
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  	after_update :crop_picture

  	# Cropping function
	def crop_picture
		# might need this line for S3?
		# profilepic.cache_stored_file!
		if crop_x.present?
		  pp "Recreating with crop"
		  picture.recreate_versions!
		end
	end

	# def bookmarked_events
	# 	@bookmarked_events = Bookmark.where(:bookmark_list_id => self.id, :bookmarked_type => "Occurrence")
	# 	@bookmarked_events.collect! do |b|
	# 		if !Occurrence.exists?(b.bookmarked_id)
	# 			nil
	# 		else
	# 			o = Occurrence.find(b.bookmarked_id)
	# 			if o.start >= Date.today.to_datetime && !o.deleted
	# 				o
	# 			else
	# 				o.event.nextOccurrence
	# 			end
	# 		end
	# 	end

	# 	return @bookmarked_events.compact
	# end
	
	def bookmarked_events(num)
		occurrences = []

		self.bookmarks.each do |bookmark|
			if(num && occurrences.size == num)
				break
			end
			
		    occurrence = bookmark.bookmarked_event

			unless(occurrence.nil?)
				occurrences.push(occurrence)
			end
		end
		return occurrences
		
		# query = "((SELECT occurrences.id AS id, occurrences.start AS start, occurrences.end AS end, events.cover_image_url, events.title, venues.name FROM occurrences
		# 		INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
		# 		INNER JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id
		# 		INNER JOIN events ON occurrences.event_id = events.id
		# 		INNER JOIN venues ON events.venue_id = venues.id
  #               WHERE bookmark_lists.id = #{self.id} AND bookmarks.bookmarked_type = 'Occurrence'
  #               	AND occurrences.recurrence_id IS NULL AND occurrences.deleted = false AND occurrences.start > now() - interval '3 hours')
		# 		UNION ALL
		# 		(SELECT DISTINCT ON (occurrences.recurrence_id) occurrences.id AS id, occurrences.start AS start, occurrences.end AS end , events.cover_image_url, events.title, venues.name FROM occurrences
		# 		INNER JOIN bookmarks ON occurrences.id = bookmarks.bookmarked_id
		# 		INNER JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id
		# 		INNER JOIN events ON occurrences.event_id = events.id
		# 		INNER JOIN venues ON events.venue_id = venues.id
        #         WHERE bookmark_lists.id = #{self.id} AND bookmarks.bookmarked_type = 'Occurrence' 
        #         	AND occurrences.recurrence_id IS NOT NULL AND occurrences.deleted = false AND occurrences.start > now() - interval '3 hours'))
		# 		ORDER BY start LIMIT #{num}";

  		# occurrences = ActiveRecord::Base.connection.select_all(query)
        # occurrences = []
        # results.each do |e|
	    #   unless e["id"].nil?
	    #   	occurrences << Occurrence.find(e["id"])
	    #   end
	    # end
        # puts occurrences
        return occurrences

	end

	def all_bookmarked_events
		@bookmarked_events = Bookmark.where(:bookmark_list_id => self.id, :bookmarked_type => "Occurrence")
		@bookmarked_events.collect! do |b|
			b.bookmarked_event
		end

		return @bookmarked_events.compact
	end

	def first_legit_bookmarked_event
		self.bookmarks.each do |bookmark|
			occurrence = bookmark.bookmarked_event
			unless(occurrence.nil?)
				return occurrence
			end
		end
		return nil
	end
end
