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
	#has_many :followed_by, :through => :bookmarks, :source => :user

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

end
