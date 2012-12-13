class PicksController < ApplicationController
helper :content
	def index
		@featuredLists = BookmarkList.where(:featured => true)
	end

	def followed
		@isFollowedLists = true
		@showAsEventsList = !params[:events].nil?

		if(@showAsEventsList)
			@lat = 30.268093
		    @long = -97.742808
		    @zoom = 11

			@occurrences = current_user.followedLists.collect { |list| list.bookmarked_events }.flatten
			render "find"
		else
			@featuredLists = current_user ? current_user.followedLists : []
			render "index"
		end
	end

	def find
		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11

		@bookmarkList = BookmarkList.find(params[:id])
		@occurrences = @bookmarkList.bookmarked_events
	end

	def myBookmarks
		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11

		@bookmarkList = current_user.main_bookmark_list
		@occurrences = @bookmarkList.bookmarked_events

		@isMyBookmarksList = true

		render "find"
	end


end
