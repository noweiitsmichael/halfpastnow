class PicksController < ApplicationController
helper :content
	def index
		@featuredLists = BookmarkList.where(:featured => true)
		puts @featuredLists
	end

	def find
		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11

		@bookmarkList = BookmarkList.find(params[:id])
		@occurrences = @bookmarkList.bookmarked_events
	end
end
