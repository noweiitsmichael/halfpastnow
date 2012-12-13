class PicksController < ApplicationController
helper :content
	def index
		@featuredLists = BookmarkList.where(:featured => true)
	end

	def followed
		@featuredLists = current_user ? current_user.followedLists : []
	end

	def find
		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11

		@bookmarkList = BookmarkList.find(params[:id])
		@occurrences = @bookmarkList.bookmarked_events
	end
end
