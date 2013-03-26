class PicksController < ApplicationController
helper :content
	def index

		@lat = 30.268093
	    @long = -97.742808
	    @zoom = 11
		query = "SELECT a.title, a.clicks, a.views, a.name, a.recurrence_id, a.start, a.id, a.event_id, a.venue_id, a.cover_image_url, a.picture_url, a.tags
				FROM
				((SELECT DISTINCT ON (events.title) events.title, events.clicks, events.views, venues.name, occurrences.recurrence_id AS recurrence_id, occurrences.start, occurrences.id, occurrences.event_id, events.venue_id, events.cover_image_url, bookmark_lists.picture_url, array_agg(events_tags.tag_id) AS tags
					FROM bookmarks 
					LEFT JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id
					LEFT JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
					LEFT JOIN events ON occurrences.event_id = events.id
					LEFT JOIN venues ON events.venue_id = venues.id
	                LEFT JOIN recurrences ON events.id = recurrences.event_id
	                LEFT JOIN events_tags ON events.id = events_tags.event_id
	                WHERE bookmarks.bookmarked_type = 'Occurrence' AND bookmark_lists.featured IS TRUE AND occurrences.recurrence_id IS NOT NULL
	                GROUP BY events.title, events.clicks, events.views, venues.name, recurrence_id, occurrences.start, occurrences.id, occurrences.event_id, events.venue_id, events.cover_image_url, bookmark_lists.picture_url)
                UNION 
                (SELECT DISTINCT ON (events.title) events.title, events.clicks, events.views, venues.name, occurrences.recurrence_id AS recurrence_id, occurrences.start, occurrences.id, occurrences.event_id, events.venue_id, events.cover_image_url, bookmark_lists.picture_url, array_agg(events_tags.tag_id) AS tags
					FROM bookmarks 
					LEFT JOIN bookmark_lists ON bookmarks.bookmark_list_id = bookmark_lists.id
					LEFT JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
					LEFT JOIN events ON occurrences.event_id = events.id
					LEFT JOIN venues ON events.venue_id = venues.id
	                LEFT JOIN recurrences ON events.id = recurrences.event_id
	                LEFT JOIN events_tags ON events.id = events_tags.event_id
	                WHERE bookmarks.bookmarked_type = 'Occurrence' AND bookmark_lists.featured IS TRUE AND occurrences.recurrence_id IS NULL AND occurrences.start < now() + INTERVAL '8 days'
	                GROUP BY events.title, events.clicks, events.views, venues.name, recurrence_id, occurrences.start, occurrences.id, occurrences.event_id, events.venue_id, events.cover_image_url, bookmark_lists.picture_url)
				) a
				ORDER BY a.clicks DESC";
		# Currently only sorting by clicks, might want to switch to popularity at some point but whatever, not that important.

        @raw_data = ActiveRecord::Base.connection.select_all(query)
        @result = []
        pp "************ RESULTS FROM QUERY ***************"

	    # Filter based on tags
        if params[:cat].nil?
        	@result = @raw_data

    		# Replace start with next Occurrence for recurring events
    		# TODO: THIS CAN BE MADE MORE EFFICIENT
    		@result.each do |oneevent|
	        	unless oneevent["recurrence_id"].blank?
	        		# puts oneevent["title"]
	        		upcoming = Occurrence.find(oneevent["id"]).event.nextOccurrence
	        		# pp upcoming
	        		unless upcoming.nil?
		        		oneevent["id"] = upcoming.id
		        		oneevent["start"] = upcoming.start
		        	end
	        	end
	        end
        else
	        @raw_data.each do |oneevent|
	        	# puts oneevent
	        	params[:cat].each do |c|
	        		if oneevent["tags"].include?(c)
		        		@result << oneevent 
		        		# Replace start with next Occurrence for recurring events
		        		# TODO: THIS CAN BE MADE MORE EFFICIENT
			        	unless oneevent["recurrence_id"].blank?
			        		# puts oneevent["title"]
			        		upcoming = Occurrence.find(oneevent["id"]).event.nextOccurrence
			        		# pp upcoming
			        		unless upcoming.nil?
				        		oneevent["id"] = upcoming.id
				        		oneevent["start"] = upcoming.start
				        	end
			        	end
		        		puts "Matched #{c} inside #{oneevent["tags"]}"
		        		next
		        	end
	        	end
	        end
	    end

	end

	def trendsetters
		query = "(SELECT DISTINCT ON (bookmark_lists.id) bookmark_lists.id, occurrences.recurrence_id AS recurrence_id, recurrences.range_end AS range_end, occurrences.start AS start,occurrences.deleted AS deleted, 
				occurrences.id AS occurrence_id, tags.id AS tag_id FROM bookmark_lists
				INNER JOIN bookmarks ON bookmark_lists.id = bookmarks.bookmark_list_id
				INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
				INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN events_tags ON events.id = events_tags.event_id
                INNER JOIN recurrences ON events.id = recurrences.event_id
                INNER JOIN tags ON events_tags.tag_id = tags.id
                WHERE bookmarks.bookmarked_type = 'Occurrence' AND bookmark_lists.featured IS TRUE AND occurrences.recurrence_id IS NOT NULL)
                UNION 
                (SELECT DISTINCT ON (bookmark_lists.id) bookmark_lists.id, occurrences.recurrence_id AS recurrence_id, occurrences.end AS range_end, occurrences.start AS start,occurrences.deleted AS deleted, 
				occurrences.id AS occurrence_id, tags.id AS tag_id FROM bookmark_lists
				INNER JOIN bookmarks ON bookmark_lists.id = bookmarks.bookmark_list_id
				INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
				INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN events_tags ON events.id = events_tags.event_id
                INNER JOIN tags ON events_tags.tag_id = tags.id
                WHERE bookmarks.bookmarked_type = 'Occurrence' AND bookmark_lists.featured IS TRUE AND occurrences.recurrence_id IS NULL)";
        result = ActiveRecord::Base.connection.select_all(query)
        # y result
	    listIDs = result.collect { |e| e["id"] }.uniq
	    tagIDs = result.collect { |e| e["tag_id"].to_i }.uniq
	    #@parentTags = Tag.all(:conditions => {:parent_tag_id => nil}).select{ |tag| tagIDs.include?(tag.id) && tag.name != "Streams" && tag.name != "Tags" }
		# puts result.uniq
		# puts result.uniq.size
		legitSet = filter_all_legit(result)
		# puts "legit set"
		# puts legitSet.size
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
		# puts legittagIDs
		@parentTags = Tag.all(:conditions => {:parent_tag_id => nil}).select{ |tag| legittagIDs.uniq.include?(tag.id) && tag.name != "Streams" && tag.name != "Tags" }
		# puts @parentTags
		# puts @parentTags.collect{ |p| p.name}
		tag_id = params[:id]
		if tag_id.to_s.empty?
			@featuredLists = BookmarkList.where(:featured=>true)
			# puts @featuredLists
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
				range_end = r["range_end"]
				# occ = Occurrence.find(id)
				if ( deleted.eql?"f" ) # !deleted
					if !recurrence_id.nil?
						if range_end.nil? || range_end.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
							# puts " 5 "
							@list << lID
						else
							# puts " 6 "
							@exclude << r 
						end
					else
						if start.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
							@list << lID
						else
							@exclude << r 
						end
					end
				else 
					if !recurrence_id.nil?
						#rec =   Recurrence.select{ |r| r.id = recurrence_id}.first
						if range_end.nil? || range_end.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
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
			# puts "Legit"
			# puts @legit
			# puts @list

			ls = []
			@list.uniq.each { |l|
				# puts "List ID"
				# puts l
				n = @legit.select{ |r| r["id"] == l.to_s }.uniq
				if n.count > 1
					# puts l
					ls << l
				end
			}
			@featuredLists = BookmarkList.find(ls)
			# puts @featuredLists
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
			range_end = r["range_end"]
			# puts r



			if ( deleted.eql?"f" )
				if !recurrence_id.nil?
					# puts " 1 "
					if range_end.nil? || range_end.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
						# puts " 5 "
						@list << lID
					else
						# puts " 6 "
						@exclude << r 
					end



				else
					if start.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
						# puts " 2 "
						@list << lID
					else
						# puts " 3 "
						@exclude << r 
					end

				end

			else 
				if !recurrence_id.nil?
					# puts " 4 "
					#rec = Recurrence.select{ |r| r.id = recurrence_id}.first
					if range_end.nil? || range_end.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
						# puts " 5 "
						@list << lID
					else
						# puts " 6 "
						@exclude << r 
					end
				else
					# puts " 7 "
					@exclude << r 
				end


			end
		}
		return @legit = result - @exclude	
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

			@occurrences = current_user.followedLists.collect { |list| list.all_bookmarked_events.select{ |o| o.start >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time } }.flatten.uniq{|x| x.id}
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
	    @url = 'http://www.halfpastnow.com/picks/find/'+params[:id]
		@occurrences = @bookmarkList.all_bookmarked_events.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time }.sort_by { |o| o.start }
	end

	def sxsw
		@events = EventsTags.where(:tag_id => 1).collect {|t| Event.find(t.event_id) }

	    respond_to do |format|
	      format.html
	      format.json { render json: @occurrences }
	    end
    #   eventsQuery = "
    #     SELECT events.name, venues.name, occurrences.start, occurrences.end
 			# FROM events, venues, occurrences
 			# WHERE events.venue_id = venues.id AND occurrences.venue_id = events.id
 			# LIMIT 10"
    #   @eventsList = ActiveRecord::Base.connection.select_all(eventsQuery)
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
		@occurrences = (!@bookmarkList.nil?) ? @bookmarkList.all_bookmarked_events.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S') }.sort_by { |o| o.start } : []

		@isMyBookmarksList = true
		@isMyTopPicksList = true
		render "find"
	end

end
