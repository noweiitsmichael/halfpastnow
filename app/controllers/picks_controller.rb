class PicksController < ApplicationController
helper :content
	def index
		query = "SELECT bookmark_lists.id, occurrences.recurrence_id AS recurrence_id, occurrences.start AS start,occurrences.deleted AS deleted, occurrences.id AS occurrence_id, tags.id AS tag_id FROM bookmark_lists
				INNER JOIN bookmarks ON bookmark_lists.id = bookmarks.bookmark_list_id
				INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
				INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN events_tags ON events.id = events_tags.event_id
                INNER JOIN tags ON events_tags.tag_id = tags.id
                WHERE bookmarks.bookmarked_type = 'Occurrence' AND bookmark_lists.featured IS TRUE"
        result = ActiveRecord::Base.connection.select_all(query)
	    listIDs = result.collect { |e| e["id"] }.uniq
	    tagIDs = result.collect { |e| e["tag_id"].to_i }.uniq
	    # @parentTags = Tag.all(:conditions => {:parent_tag_id => nil}).select{ |tag| tagIDs.include?(tag.id) && tag.name != "Streams" && tag.name != "Tags" }
		
		legitSet = filter_all_legit(result)
		# puts "legit set"
		# puts legitSet
		legittagIDs = []
		tagIDs.each { |tagID|
			set = legitSet.select{ |r| r["tag_id"] == tagID.to_s }.uniq
			# puts "Set herer"
			set1 = set.collect { |e| {:id => e["id"], :tag_id => e["tag_id"]}  }
			# puts set1
			if set1.size > set1.uniq.size
				# puts "TagID"
				# puts tagID
				legittagIDs << tagID
			end
		}
		@parentTags = Tag.all(:conditions => {:parent_tag_id => nil}).select{ |tag| legittagIDs.uniq.include?(tag.id) && tag.name != "Streams" && tag.name != "Tags" }
		
		# puts @parentTags.collect{ |p| p.name}
		tag_id = params[:id]
		if tag_id.to_s.empty?
			@featuredLists = BookmarkList.where(:featured=>true)
		else
			@list=[]
			@exclude=[]
			rs = result.select { |r| r["tag_id"] == tag_id.to_s }.uniq
			rs.uniq.each{ |r|
				id = r["occurrence_id"]
				lID = r["id"]
				recurrence_id = r["recurrence_id"]
				deleted = r["deleted"]
				start = r["start"]
				if ( deleted.eql?"f" ) # !deleted
					if !recurrence_id.nil?
						@list << lID
					else
						if Date.strptime(start) > Date.today()
							@list << lID
						else
							@exclude << r 
						end

					end
					
				else 
					if !recurrence_id.nil?
						rec = Recurrence.find(recurrence_id)
						if rec.range_end.nil? || rec.range_end > Date.today()
							@list << lID
						else
							@exclude << r 
						end
					else
						@exclude << r 
					end


				end
			}
			@legit = rs - @exclude
			ls = []
			@list.each { |l|
				n = @legit.select{ |r| r["id"] == l.to_s }.uniq
				if n.count > 1
					ls << l
				end
			}
			@featuredLists = BookmarkList.find(ls)

			# @featuredLists = BookmarkList.find(result.select { |r| r["tag_id"] == tag_id.to_s }.collect { |e| e["id"] }.uniq)
		end
	end

	def filter_all_legit(result)
		@list=[]
		@exclude=[]
		
		result.uniq.each{ |r|
			id = r["occurrence_id"]
			lID = r["id"]
			recurrence_id = r["recurrence_id"]
			deleted = r["deleted"]
			# occ = Occurrence.find(id)
			start = r["start"]
			if ( deleted.eql?"f" )
				if !recurrence_id.nil?
					@list << lID
				else
					if Date.strptime(start) > Date.today()
						@list << lID
					else
						@exclude << r 
					end

				end
				
			else 
				if !recurrence_id.nil?
					rec = Recurrence.find(recurrence_id)
					if rec.range_end.nil? || rec.range_end > Date.today()
						@list << lID
					else
						@exclude << r 
					end
				else
					@exclude << r 
				end


			end
		}
		@legit = result - @exclude	
	end

	# @listIDs=[]
	# 		result.uniq.each{ |r|
	# 			id = r["id"]
	# 			if BookmarkList.find(id).all_bookmarked_events.size > 0
	# 				@listIDs << id
	# 			end
	# 		}
	# 		@featuredLists = BookmarkList.find(@listIDs)
	def followed
		@parentTags = Tag.all(:conditions => {:parent_tag_id => nil})
		@isFollowedLists = true
		@showAsEventsList = !params[:events].nil?
        
		if(@showAsEventsList)
			@lat = 30.268093
		    @long = -97.742808
		    @zoom = 11

			@occurrences = current_user.followedLists.collect { |list| list.all_bookmarked_events.select{ |o| o.start >= Date.today.to_datetime } }.flatten.uniq{|x| x.id}
			render "find"
		else
			@featuredLists = current_user ? current_user.followedLists : []
			render "index"
		end
	end

	def find
		@pick = true
		@bookmarkList = BookmarkList.find(params[:id])
		@pageTitle =  @bookmarkList.name + " | half past now."
		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11
	    @url = 'http://halfpastnow.com/picks/find/'+params[:id]
		@occurrences = @bookmarkList.all_bookmarked_events.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time }.sort_by { |o| o.start }
		
		
		
		
	end

	def myBookmarks
		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11

		@bookmarkList = current_user.main_bookmark_list
		@occurrences = @bookmarkList.all_bookmarked_events.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time }.sort_by { |o| o.start }

		@isMyBookmarksList = true

		render "find"
	end

	def myTopPicks
		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11

		@bookmarkList = BookmarkList.where(:user_id => current_user.id, :featured => true).first
		@occurrences = (!@bookmarkList.nil?) ? @bookmarkList.all_bookmarked_events.select{ |o| o.start >= Date.today.to_datetime }.sort_by { |o| o.start } : []

		@isMyBookmarksList = true
		@isMyTopPicksList = true
		render "find"
	end

end
