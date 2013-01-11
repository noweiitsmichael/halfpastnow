require 'net/http'
require 'rexml/document'
require 'pp'
require 'htmlentities'
require 'rubygems'
require 'sanitize'
require 'eventful/api'
require 'carrierwave'
include REXML

namespace :test do 
	desc "advance timestamps of events' occurrences"
	task :advance => :environment do
		first_occurrence = Occurrence.order("start").first
		difference_in_days = Date.today - first_occurrence.start.to_date
		Occurrence.all.each do |occurrence| 
			occurrence.start = occurrence.start.advance({:days => difference_in_days})
			if(occurrence.end)
				occurrence.end = occurrence.end.advance({:days => difference_in_days})
			end
			occurrence.save
		end
	end
end

namespace :m do 
	## Random helper commands

	# # update completedness if it errors out
	# Venue.find(:all).each {|d| d.completion = d.completedness; d.save!;}
	# Event.find(:all).each {|d| d.completion = d.completedness; d.save!;}

	desc "migrating bookmarks..."
	task :bookmarks => :environment do
		User.all.each do |u|
			main_bookmarks_list = BookmarkList.where(:user_id => u.id, :main_bookmarks_list => true)
			if main_bookmarks_list.empty?
				new_list = BookmarkList.create(:name => "Bookmarks", :description => "Bookmarks", :public => false, 
									:featured => false, :main_bookmarks_list => true, :user_id => u.id)
				Bookmark.where(:user_id => u.id).each do |b|
					b.bookmark_list_id = new_list.id
					b.save
				end
			end
		end
	end

	desc "bumping up bookmarked events"
	task :bookmark_bump => :environment do
		Bookmark.where(:bookmark_list_id => [92,93,95,96,98,99,100,101,102,103,105,113]).each do |b|
			if b.bookmarked_type == "Occurrence"
				unless Occurrence.where(:id => b.bookmarked_id).empty?
					e = Occurrence.find(b.bookmarked_id).event
					e.clicks = e.clicks + 100
					e.save!
				end
			end
		end
	end

	task :test => :environment do
		# for i in 6..8
		# 	for j in 0..5
		# 	   if j < 2 then
		# 	      next
		# 	   else
		# 	   		puts "Value of local variable is #{j}"
		# 	   end
		# 	end
		# 	puts "Value is #{i}"
		# end

		# if "324222ffdfae".to_datetime > Date.today 
		# 	EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => recur_event['id'], :data_type => "instance", 
		# 						:element_type => "RawEvent", :element_id => new_event.id , :data => inst + time_shifter) rescue nil
		# end 
		# puts "yay"

		for i in 0..2	

			puts "Page #{i+1}"
			puts ""	
		   eventful = Eventful::API.new '24BqTx7vtBvRCxVP'

		   # This is the cool part!
		   resultCount = eventful.call 'events/search',
				             :keywords => '',
				             :location => 'Austin',
				             :sort_order => 'relevance',
				             :page_size => 10,
				             :page_number => i+1
		   
		   puts "Results: #{resultCount['total_items']}"
		   resultCount['events']['event'].each do |r|
		      puts r['title']
		   end
		end
	end

	desc "migrating pick lists..."
	task :lists => :environment do
		parent_id = Tag.find_by_name("Streams").id;
		Tag.where(:parent_tag_id => parent_id).each do |t| # For each tag that currently represents a list
			
			EventsTags.where(:tag_id => t.id).each do |le| # For each relationship that currently represents Events-List
				puts "Working on Stream called #{t.name}"
				if BookmarkList.find_by_name(t.name).nil?
					new_list = BookmarkList.create(:name => t.name, :description => t.name, :public => true, 
									:featured => true, :main_bookmarks_list => false, :user_id => "17")
					puts "!!!Created BookmarkList for #{t.name}"
					listId = new_list.id
				else
					listId = BookmarkList.find_by_name(t.name).id
				end
				unless Event.find(le.event_id).nextOccurrence.nil?
					b = Bookmark.create(:bookmarked_type => "Occurrence", :bookmarked_id => Event.find(le.event_id).nextOccurrence.id, :bookmark_list_id => listId)
					puts "!!!!Created bookmark for #{Event.find(le.event_id).title}"
				end
			end

			ActsTags.where(:tag_id => t.id).each do |le| # For each relationship that currently represents Events-List
				if BookmarkList.find_by_name(t.name).nil?
					new_list = BookmarkList.create(:name => t.name, :description => t.name, :public => true, 
									:featured => true, :main_bookmarks_list => false, :user_id => "17")
					listId = new_list.id
				else
					listId = BookmarkList.find_by_name(t.name).id
				end

				Bookmark.create(:bookmarked_type => "Act", :bookmarked_id => le.act_id, :bookmark_list_id => listId)
				puts "!!!Created bookmark for #{Act.find(le.act_id).name}"
			end

			if BookmarkList.find_by_name(t.name).nil?
				BookmarkList.create(:name => t.name, :description => t.name, :public => true, 
									:featured => true, :main_bookmarks_list => false, :user_id => "17")
			end
		end
	end
end

desc "discard old occurrences and create new ones from recurrences"
task :update_occurrences => :environment do
	puts "update_occurrences"
	old_occurrences = Occurrence.where(:start => (DateTime.new(1900))..(DateTime.now))
	old_occurrences.each do |occurrence|
		event = occurrence.event
		puts "occurrence id: " + occurrence.id.to_s
		#if occurrence doesn't have a recurrence, then just delete it
		#otherwise, try to generate more occurrences from the recurrence.
			#if it can't, and the occurrence is the only occurrence of the recurrence, then destroy the recurrence
		if occurrence.recurrence.nil?
			occurrence.delete
		else
			if (!occurrence.recurrence.gen_occurrences(1) && occurrence.recurrence.occurrences.size == 1)
				occurrence.recurrence.delete
			else
				occurrence.recurrence.save
				occurrence.delete
			end
		end
		## Probably never want to delete events either so we always have the data
		
		# if (event.occurrences.length == 0)
		# 	event.destroy
		# end
	end
end

desc "bind parent tags to events"
task :bind_parent_tags => :environment do
	
	Event.all.each do |event|
		pp event
		event.tags.each do |tag|
			unless(tag.parentTag.nil? || event.tags.include?(tag.parentTag))
				event.tags.push(tag.parentTag)
				puts "pushed " + tag.parentTag.name
			end
		end
		event.save
	end
end

namespace :db do

	desc "load in tags and raw venues"
	task :init, [:location] => :environment do |t, args|
		location = args[:location] || "development"
		system("psql myapp_" + location + " < tags.dump")
		system("psql myapp_" + location + " < raw_venues_austin360.dump")
		system("rake api:convert_venues")
	end
end

desc "add new user [:email, :password, :username, :firstname, :lastname]"
task :new_user, [:email, :password, :username, :firstname, :lastname] => :environment do |t, args|
	@user = User.new({:email => args[:email], :password => args[:password], :password_confirmation => args[:password], :username => args[:username], :firstname => args[:firstname], :lastname => args[:lastname]})
	@user.save
end


namespace :api do

	desc "generate venues from raw_venues"
	task :convert_venues => :environment do
		raw_venues = RawVenue.all
		raw_venues.each do |raw_venue| 
			venue = Venue.create({
				:name => raw_venue.name,
				:address => raw_venue.address,
				:address2 => raw_venue.address2,
				:city => raw_venue.city,
				:state => raw_venue.state_code,
				:zip => raw_venue.zip,
				:latitude => raw_venue.latitude,
				:longitude => raw_venue.longitude,
				:phonenumber => raw_venue.phone,
				:url => raw_venue.url,
				:description => raw_venue.description
			})
			raw_venue.venue_id = venue.id
			raw_venue.save
		end
	end

	desc "pull eventful data"
	task :get_eventful_data => :environment do
		# First, create our Eventful::API object
		eventful = Eventful::API.new '24BqTx7vtBvRCxVP'

		# This is the cool part!
		resultCount = eventful.call 'events/search',
		                       :keywords => '',
		                       :location => 'Austin',
		                       :sort_order => 'relevance',
		                       :page_size => 100

		puts "Num Results #{resultCount['total_items']}"
		puts "Page Size: #{resultCount['page_size']}"
		puts "Page Count: #{resultCount['page_count']}"
		puts "page Number: #{resultCount['page_number']}"
		puts "page Items: #{resultCount['page_items']}"
		puts "Events Length: #{resultCount['events']['event'].count}"

		numResults = resultCount['total_items']
		pageNumber = 1

		while pageNumber <= resultCount['page_count'] #(numResults/100)
			events = eventful.call 'events/search',
                       :keywords => '',
                       :location => 'Austin',
		               :sort_order => 'relevance',
                       :page_size => 100,
                       :page_number => pageNumber

            puts "Num Results: #{events['total_items']}"
            puts "Total Pages: #{resultCount['page_count']}"
            puts "PAGENUMBER= #{pageNumber}"

			# If we couldn't find anything, quit
			if events['events'].nil? then
			 puts "The frack? I couldn't find anything. Sorry."
			 return
			end
			# event = events['events']['event'] # for testing
			events['events']['event'].each do |event|
				puts "*****Processing Event called #{event['title']} #{event['id']}"
				time_shifter = 0
				# pp event
				# pp events['events']
				
				if event['venue_id'] != nil && !event['venue_name'].blank?

########## First check to see if venue exists ###########
					puts "....checking venue"
					venue = eventful.call 'venues/get',
											:id => event['venue_id']
					# pp venue['name']
					if venue["description"] == "There is no venue with that identifier."
					 puts "skipping because location doesn't seem to exist"
					 next
					end

					# Add RawVenue unless it already exists
					if RawVenue.where(:from => "eventful", :raw_id => venue['id']).empty?
						puts "Creating rawvenue with id #{venue['id']}"

						raw_venue = RawVenue.create!(
							:name => venue['name'],
							:address => venue['address'],
							:city => venue['city'],
							:state_code => venue['region_abbr'],
							:zip => venue['postal_code'],
							:latitude => venue['latitude'],
							:longitude => venue['longitude'],
							# :phone => venue['phone'],
							# :url => venue['website'],
							:description => venue['description'],
							:raw_id => venue['id'],
							:from => "eventful"
						)
						raw_venue.save
					
						# Now make actual venue if it doesn't already exist

						#regex_replace( regex_replace( regexp_replace(lower("The Breaker's of the World"), '\'', ''), '^the ', ''), ' the ', ' ')
						if Venue.find(:first, :conditions => [ "lower(name) = ?", venue['name'].downcase ]) == nil
							puts "....Creating real venue for #{venue['name']} #{venue['id']}"
							new_venue = Venue.create!(
								:name => raw_venue.name,
								:address => raw_venue.address,
								:city => raw_venue.city,
								:state => raw_venue.state_code,
								:zip => raw_venue.zip,
								:latitude => raw_venue.latitude,
								:longitude => raw_venue.longitude,
								:phonenumber => raw_venue.phone,
								:url => raw_venue.url,
								:description => raw_venue.description,
								:fb_picture => raw_venue.fb_picture
							)
							raw_venue.venue_id = new_venue.id
							raw_venue.save

							# Save links
							if !venue['links'].nil? 
								if venue['links']['link'].instance_of?(Array)
									venue['links']['link'].each do |link|
										puts "Saving Links..."
										 puts new_venue.id
										# pp link
										EventfulData.create(:eventful_origin_type => "Venue", :eventful_origin_id => venue['id'], :data_type => "link", 
															:element_type => "Venue", :element_id => new_venue.id.to_i , :data => link['url'], :data2 => link['type'], :data3 => link['time'])
									end
								elsif venue['links']['link'].instance_of?(Hash)
									puts "Saving Links..."
										puts new_venue.id
										# pp venue['links']['link']
										EventfulData.create(:eventful_origin_type => "Venue", :eventful_origin_id => venue['id'], :data_type => "link", 
															:element_type => "Venue", :element_id => new_venue.id.to_i , :data => venue['links']['link']['url'], :data2 => venue['links']['link']['type'], :data3 => venue['links']['link']['time'])
								end
							end

							# # Create pictures
							if !venue['images'].nil? 
								if venue['images']['image'].instance_of?(Array)
									venue['images']['image'].each do |pic|
										puts "Saving venue pictures from...."
										# pp open(pic['url'].gsub("/images/small/", "/images/original/"))
										Picture.create(:pictureable_id => new_venue.id, :pictureable_type => "Venue", 
												   	   :image => open(pic['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
									end
								elsif venue['images']['image'].instance_of?(Hash)
										puts "Saving venue pictures from...."
										# pp venue['images']['image']
										# pp open(venue['images']['image']['url'].gsub("/images/small/", "/images/original/"))
										Picture.create(:pictureable_id => new_venue.id, :pictureable_type => "Venue", 
												   	   :image => open(venue['images']['image']['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
								end
							end

						else
							puts "Venue already exists for " + venue['name']
							raw_venue.venue_id = Venue.find(:first, :conditions => [ "lower(name) = ?", venue['name'].downcase ]).id
							raw_venue.save
						end
					else
						puts "Venue info for " + venue['name'] + " already exists"
					end

########## Now add to Raw Events ############
					if Event.find_by_title(event['title']) == nil && RawEvent.where(:title => event['title'], :from => "eventful").empty?
						puts "....Creating event " + event['title'] + " for " + event['venue_name'] + " " + event['venue_id']
						puts "--------------Time Start #{event['start_time']}"
						 pp event
						
						if event['start_time'].instance_of? (String)
							puts "CHECK THIS TIME!!!!!!!!!!"
							event['start_time'] = Time.parse(event['start_time'])
							if event['stop_time'].instance_of? (String)
								event['stop_time'] = Time.parse(event['stop_time'])
							end
						elsif event['start_time'].zone == "CST"
							time_shifter = 6.hours
						elsif event['start_time'].zone == "CDT" 
							time_shifter = 5.hours
						end
						if event['start_time'].instance_of? (String)
							puts "still string....."
						end
						puts "Adding #{event['id']} starting at #{event['start_time']} offset by #{time_shifter}"
						new_event = RawEvent.create!(
							:title => event['title'],
							:description => event['description'],
							:start => event['start_time'] + time_shifter,
							:end => event['stop_time'].nil? ? nil : event['stop_time'] + time_shifter,
							# :url => event['website'],
							:raw_venue_id => RawVenue.find_by_raw_id(event['venue_id'].to_s).id,
							:from => "eventful",
							:raw_id => event['id']
						)
						
						# Create Links
						if event['link_count'] == nil
							new_event.url = event['url']
							new_event.save!
						elsif !event['links'].nil? 
							if event['links']['link'].instance_of?(Array)
								event['links']['link'].each do |link|
									puts "Saving Links..."
									EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => event['id'], :data_type => "link", 
														:element_type => "Event", :element_id => new_event.id , :data => link['url'], :data2 => link['type'], :data3 => link['time']) rescue nil
								end
							elsif event['links']['link'].instance_of?(Hash)
								puts "Saving Link..."
								EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => event['links']['link']['id'], :data_type => "link", 
													:element_type => "Event", :element_id => new_event.id , :data => event['links']['link']['url'], :data2 => event['links']['link']['type'], :data3 => event['links']['link']['time']) rescue nil
							end
						end

						# Create pictures
						if !event['images'].nil? 
							if event['images']['image'].instance_of?(Array)
								event['images']['image'].each do |pic|
									puts "Saving pictures...."
									# pp open(pic['url'].gsub("/images/small/", "/images/original/"))
									Picture.create(:pictureable_id => new_event.id, :pictureable_type => "RawEvent", 
												   :image => open(pic['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
								end
							elsif event['images']['image'].instance_of?(Hash)
								puts "Saving picture...., inside"
								# pp open(event['images']['image']['url'].gsub("/images/small/", "/images/original/"))
								Picture.create(:pictureable_id => new_event.id, :pictureable_type => "RawEvent", 
											   :image => open(event['images']['image']['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
							end
						else
							puts "No images processed"
						end

						# Create tags
						if !event['categories'].nil? 
							if event['categories']['category'].instance_of?(Array)
								event['categories']['category'].each do |tag|
									puts "Saving tags..."
									EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => event['id'], :data_type => "tag", 
														:element_type => "Event", :element_id => new_event.id , :data => tag['name'], :data2 => tag['id']) rescue nil
								end
							elsif event['categories']['category'].instance_of?(Hash)
								puts "Saving tag..."
								EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => ['id'], :data_type => "tag", 
													:element_type => "Event", :element_id => new_event.id , :data => event['categories']['category']['name'], :data2 => event['categories']['category']['id']) rescue nil
							end
						end

						# Check to see if it is a recurring event
						if !event['recur_string'].blank?
							puts "logging recurrence"
							puts event['recur_string']
							EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => event['id'], :data_type => "recurrence", 
												:element_type => "RawEvent", :element_id => new_event.id , :data => event['recur_string'])

							if event['recur_string'] == "on various days"
								recur_event = eventful.call 'events/get', :id => event['id']
								# pp recur_event
								if !recur_event['recurrence']['rdates'].nil?
									if recur_event['recurrence']['rdates']['rdate'].instance_of?(Array)
										recur_event['recurrence']['rdates']['rdate'].each do |inst|
											puts "creating recurrence for #{inst}"
											# pp inst
											if inst.to_datetime > Date.today 
												EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => recur_event['id'], :data_type => "instance", 
																	:element_type => "RawEvent", :element_id => new_event.id , :data => inst + time_shifter) rescue nil
											end rescue nil
										end
									elsif recur_event['recurrence']['rdates']['rdate'].instance_of?(Hash)
										puts "creating recurrence"
											pp inst
											EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => recur_event['id'], :data_type => "instance", 
												:element_type => "RawEvent", :element_id => new_event.id , :data => recur_event['recurrence']['rdates']['rdate'] + time_shifter)  rescue nil
									end
								end
							else
								puts "----------------------------Not on various days"
							end
						end

						puts "Successfully created event for " + event['title']


############## Now create artists ################
						puts "....checking artists"
						if !event['performers'].nil?
							if event['performers']['performer'].instance_of?(Array)
								event['performers']['performer'].each do |perf|
									if Act.find(:first, :conditions => [ "lower(name) = ?", perf['name'].downcase ]) == nil
										performer = eventful.call 'performers/get', :id => perf['id']
										puts "Creating performer with id #{perf['id']} "
										# Create Act
										new_act = Act.create!(
											:name => performer['name'],
											:description => performer['short_bio'],
											:bio => performer['long_bio'],
											:pop_id => performer['id'],
											:pop_likes => performer['demand_member_count'],
											:pop_link => performer['url'],
											:pop_source => "eventful"

										)

										# Save links
										if !performer['links'].nil? 
											if performer['links']['link'].instance_of?(Array)
												performer['links']['link'].each do |link|
													puts "Saving Links..."
													EventfulData.create(:eventful_origin_type => "Performer", :eventful_origin_id => performer['id'], :data_type => "link", 
																		:element_type => "Act", :element_id => new_act.id, :data => link['url'], :data2 => link['type'], :data3 => link['time']) rescue nil
												end
											elsif performer['links']['link'].instance_of?(Hash)
												puts "Saving Link..."
													EventfulData.create(:eventful_origin_type => "Performer", :eventful_origin_id => performer['id'], :data_type => "link", 
																		:element_type => "Act", :element_id => new_act.id , :data => performer['links']['link']['url'], :data2 => performer['links']['link']['type'], :data3 => performer['links']['link']['time']) rescue nil
											end
										end

										# Create pictures
										if !performer['images'].nil? 
											if performer['images']['image'].instance_of?(Array)
												performer['images']['image'].each do |pic|
													puts "Saving performer pictures...."
													Picture.create(:pictureable_id => new_act.id, :pictureable_type => "Act", 
															   	   :image => open(pic['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
												end
											elsif performer['images']['image'].instance_of?(Hash)
													puts "Saving performer pictures...."
													Picture.create(:pictureable_id => new_act.id, :pictureable_type => "Act", 
															   	   :image => open(performer['images']['image']['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
											end
										end

										# Create tags
										if !performer['tags'].nil? 
											if performer['tags']['tag'].instance_of?(Array)
												performer['tags']['tag'].each do |tag|
													puts "Saving tags..."
													EventfulData.create(:eventful_origin_type => "Performer", :eventful_origin_id => performer['id'], :data_type => "tag", 
																		:element_type => "Act", :element_id => new_act.id , :data => tag['title'], :data2 => tag['id']) rescue nil
												end
											elsif performer['tags']['tag'].instance_of?(Hash)
												puts "Saving tag..."
												EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => ['id'], :data_type => "tag", 
																	:element_type => "Event", :element_id => new_act.id , :data => performer['tags']['tag']['title'], :data2 => event['tags']['tag']['id']) rescue nil
											end
										end

										# Mark categories
										if !performer['categories'].nil? 
											category_string = ""
											if performer['categories']['category'].instance_of?(Array)
												performer['categories']['category'].each do |cat|
													category_string += cat['id']
													category_string += ", "
												end
											elsif performer['categories']['category'].instance_of?(Hash)
												category_string = performer['categories']['category']['id']
											end
											new_act.genre = category_string
											new_act.save!
										end
									end
								end

							elsif event['performers']['performer'].instance_of?(Hash)
								if Act.find(:first, :conditions => [ "lower(name) = ?", event['performers']['performer']['name'].downcase ]) == nil
									puts "Creating new act"
									performer = eventful.call 'performers/get', :id => event['performers']['performer']['id']
									puts "Creating performer with id #{event['performers']['performer']['id']} "
									# Create Act
									new_act = Act.create!(
										:name => performer['name'],
										:description => performer['short_bio'],
										:bio => performer['long_bio'],
										:pop_id => performer['id'],
										:pop_likes => performer['demand_member_count'],
										:pop_link => performer['url'],
										:pop_source => "eventful"

									)

									# Save links
									if !performer['links'].nil? 
										if performer['links']['link'].instance_of?(Array)
											performer['links']['link'].each do |link|
												puts "Saving Links..."
												EventfulData.create(:eventful_origin_type => "Performer", :eventful_origin_id => performer['id'], :data_type => "link", 
																	:element_type => "Act", :element_id => new_act.id, :data => link['url'], :data2 => link['type'], :data3 => link['time']) rescue nil
											end
										elsif performer['links']['link'].instance_of?(Hash)
											puts "Saving Link..."
												EventfulData.create(:eventful_origin_type => "Performer", :eventful_origin_id => performer['id'], :data_type => "link", 
																	:element_type => "Act", :element_id => new_act.id , :data => performer['links']['link']['url'], :data2 => performer['links']['link']['type'], :data3 => performer['links']['link']['time']) rescue nil
										end
									end

									# # Create pictures
									if !performer['images'].nil? 
										if performer['images']['image'].instance_of?(Array)
											performer['images']['image'].each do |pic|
												puts "Saving performer pictures...."
												Picture.create(:pictureable_id => new_act.id, :pictureable_type => "Act", 
														   	   :image => open(pic['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
											end
										elsif performer['images']['image'].instance_of?(Hash)
												puts "Saving venue pictures...."
												Picture.create(:pictureable_id => new_act.id, :pictureable_type => "Act", 
														   	   :image => open(performer['images']['image']['url'].gsub("/images/small/", "/images/original/")) ) rescue nil
										end
									end

									# Create tags
									if !performer['tags'].nil? 
										if performer['tags']['tag'].instance_of?(Array)
											performer['tags']['tag'].each do |tag|
												puts "Saving tags..."
												EventfulData.create(:eventful_origin_type => "Performer", :eventful_origin_id => performer['id'], :data_type => "tag", 
																	:element_type => "Act", :element_id => new_act.id , :data => tag['title'], :data2 => tag['id']) rescue nil
											end
										elsif performer['tags']['tag'].instance_of?(Hash)
											puts "Saving tag..."
											EventfulData.create(:eventful_origin_type => "Event", :eventful_origin_id => ['id'], :data_type => "tag", 
																:element_type => "Event", :element_id => new_act.id , :data => performer['tags']['tag']['title'], :data2 => performer['tags']['tag']['id']) rescue nil
										end
									end

									# Mark categories
									if !performer['categories'].nil? 
										category_string = ""
										if performer['categories']['category'].instance_of?(Array)
											performer['categories']['category'].each do |cat|
												category_string += cat['id']
												category_string += ", "
											end
										elsif performer['categories']['category'].instance_of?(Hash)
											category_string = performer['categories']['category']['id']
										end
										new_act.genre = category_string
										new_act.save!
									end
								end
							end

						else
							puts "Performer #{venue['name']} already exists"
						end

					else
						puts "Event #{event['title']} already exists!"
					end

				end
			# # Output the results
			 end

			pageNumber = pageNumber + 1
			puts "Yay! moving on to page #{pageNumber}"
		end
		# end
	end

	desc "pull venues from facebook events"
	task :get_fb_events => :environment do
		access_token = User.find_by_email("noweiitsmichael@yahoo.com").fb_access_token
		puts "Pulling from Facebook. IS IT DAYLIGHT SAVINGS TIME YET?!?!?!?!?!?!?!?!?!?!??!?!?!?!?!??!?!?!?!?!?!?!??!?!?!?!"
		no_id = false
		@graph = Koala::Facebook::API.new(access_token)
		## Pull all things that halfpastnow likes
		@graph.get_connections("halfpastnow","likes").each do |like|
			edited_already = false
			## Now pull the events from all things halfpastnow likes. Should work even if nil
			@graph.get_connections(like['id'],"events", :fields => 'location,venue,name,description').each do |events|
				no_id = false
				
				## if the name or location is blank, we're just gonna skip it
				if events['name'].blank? || events['location'].blank? 
					puts "skipping because no location..."
					next
				end

				## Get location of each event and create if doesn't exist
				if Venue.find_by_name(events['location']) == nil  # && (events['venue'] != nil || events['location'] != nil)
					puts "No existing venue found for " + events['name'] + " @ " + events['location']

					allowed_cities = ['Austin', 'Round Rock', 'Cedar Park', 'San Marcos', 'Georgetown', 'Pflugerville',
								   'Kyle', 'Leander', 'Bastrop', 'Brushy Creek', 'Buda', 'Dripping Springs', 'Elgin',
								   'Hutto', 'Jollyville', 'Lakeway', 'Lockhart', 'Luling', 'Shady Hollow', 'Taylor',
								   'Wells Branch', 'Windemere', 'Marble Falls', 'Burnet', 'Johnson City', 'La Grange',
								   'Killeen', 'Lampasas', 'Fredericksburg']
					## Find venue by listed ID
					if events['venue'] != nil
						if events['venue']['id'] != nil #need this because 'venue' of nil will throw error when looking for 'id'
							fb_venue = @graph.get_object(events['venue']['id'])
							if fb_venue['location']['city'].nil?
								puts "skipping because location does not specify city (meaning not real location/event)..."
								next
							end
								puts "Creating rawvenue with id " + events['venue']['id'] + " in " + fb_venue['location']['city']
							if !allowed_cities.include?(fb_venue['location']['city'])
								puts "skipping because " + fb_venue['location']['city'] + " is not in Greater Austin Area..."
								next
							end
							raw_venue = RawVenue.create!(
								:name => fb_venue['name'],
								:address => fb_venue['location']['street'],
								:city => fb_venue['location']['city'],
								:state_code => fb_venue['location']['state'],
								:zip => fb_venue['location']['zip'],
								:latitude => fb_venue['location']['latitude'],
								:longitude => fb_venue['location']['longitude'],
								:phone => fb_venue['phone'],
								:url => fb_venue['website'],
								:description => fb_venue['about'],
								:raw_id => fb_venue['id'],
								:from => "facebook"
							)
							raw_venue.fb_picture = @graph.get_picture(fb_venue['id'], :type => "large")
							raw_venue.save
						
						## Some n00bs don't know how to link to FB venues and input manual location.
						else
							puts "Manually creating venue: " + events['location']
							stupid_fake_venues = ['Online', 'online', 'web', 'Web', 'Website', 'website']
							if stupid_fake_venues.include?(events['location']) || events['venue']['city'].nil?
								puts "skipping because " + events['location'] + " is not a actual location..."
								next
							end
							if  !allowed_cities.include?(events['venue']['city'])
								puts "skipping because " + events['venue']['city'] + " is not in Greater Austin Area..."
								next
							end

							raw_venue = RawVenue.create!(
								:name => events['location'],
								:address => events['venue']['street'],
								:city => events['venue']['city'],
								:state_code => events['venue']['state'],
								:zip => events['venue']['zip'],
								:from => "facebook"
							)
						end
					end
					## Now make actual venue
					if events['venue'] != nil
						puts "Creating real venue for " + raw_venue.name
						venue = Venue.create!(
							:name => raw_venue.name,
							:address => raw_venue.address,
							:city => raw_venue.city,
							:state => raw_venue.state_code,
							:zip => raw_venue.zip,
							:latitude => raw_venue.latitude,
							:longitude => raw_venue.longitude,
							:phonenumber => raw_venue.phone,
							:url => raw_venue.url,
							:description => raw_venue.description,
							:fb_picture => raw_venue.fb_picture
						)
						raw_venue.venue_id = venue.id
						raw_venue.save
					end

					if events['venue'] == nil
						no_id = true
					end
				else
					## Updating existing venue with FB information
					if events['venue'] != nil && edited_already == false
						if events['venue']['id'] != nil
							fb_venue = @graph.get_object(events['venue']['id'])
							raw_venue = RawVenue.find_by_name(events['location'])
							real_venue = Venue.find_by_name(events['location'])
							puts "Venue found, updating venue: " + fb_venue['name']

							if real_venue.address.blank? == true
								raw_venue.address = fb_venue['location']['street']
								real_venue.address = fb_venue['location']['street']

							end

							if real_venue.city.blank? == true
								raw_venue.city = fb_venue['location']['city']
								real_venue.city = fb_venue['location']['city']
							end

							if real_venue.state.blank? == true
								raw_venue.state_code = fb_venue['location']['state']
								real_venue.state = fb_venue['location']['state']
							end

							if real_venue.url.blank? == true
								raw_venue.url = fb_venue['website']
								real_venue.url = fb_venue['website']
							end

							if real_venue.description.blank? == true
								raw_venue.description = fb_venue['about']
								real_venue.description = fb_venue['about']
							end

							if real_venue.phonenumber.blank? == true
								raw_venue.phone = fb_venue['phone']
								real_venue.phonenumber = fb_venue['phone']
							end

							raw_venue.zip = fb_venue['location']['zip']
							real_venue.zip = fb_venue['location']['zip']
							raw_venue.latitude = fb_venue['location']['latitude']
							real_venue.latitude = fb_venue['location']['latitude']
							raw_venue.latitude = fb_venue['location']['longitude']
							real_venue.latitude = fb_venue['location']['longitude']
							raw_venue.from = "facebook"
							raw_venue.fb_picture = @graph.get_picture(fb_venue['id'], :type => "large")
							real_venue.fb_picture = @graph.get_picture(fb_venue['id'], :type => "large")
							raw_venue.save
							real_venue.save
							edited_already = true
						end
					end

				end

				## Now that location has been confirmed, put in events
				if Event.find_by_title(events['name']) == nil && RawEvent.find_by_title(events['name']) == nil && no_id != true
					event = RawEvent.create!(
						:title => events['name'],
						:description => events['description'],
						:start => events['start_time'],
						:end => events['end_time'],
						:url => events['website'],
						:raw_venue_id => RawVenue.find_by_name(events['location']).id,
						:from => "facebook",
						:raw_id => events['id']
					)
					
					## time zone timezone hack :( probably needs to be fixed soon
					## Dunno why facebook returns a time that is off by one hour. Daylight Savings?
					if events['start_time'] != nil
						event.start = event.start.to_datetime # + 1.hours
					end

					if events['end_time'] != nil
						event.end = event.end.to_datetime + 1.hours
					end
					event.fb_picture = @graph.get_picture(events['id'], :type => "large")
					event.save!
					puts "Successfully created event for " + events['name']
				end
			end
		end
	end


	desc "pull venues from facebook events"
	task :get_fb_artists => :environment do
		access_token = User.find_by_email("noweiitsmichael@yahoo.com").fb_access_token
		@graph = Koala::Facebook::API.new(access_token)

		puts "Pulling artists from Facebook"

		## Pull all things that halfpastnow likes
		artists = @graph.get_connections("halfpastnow","likes")

		## Parse out everything that's not a Musician/band
		artists.delete_if { |x| x['category'] != "Musician/band"}

		## Take each liked musician...
		artists.each do |liked_artists|
			## And get their full profile based on id
			#pp liked_artists
			full_artist = @graph.get_object(liked_artists['id'])
			full_artist['name'] = full_artist['name'].titleize()
			#puts full_artist['name']
			search_artist = Act.find_by_name(full_artist['name']) 
			#pp search_artist
			if search_artist == nil
				puts "New artist found: " + full_artist['name']
				new_artist = Act.create!(
					:name => full_artist['name'],
					:description => full_artist['description'],
					:website => full_artist['website'],
					:genre => full_artist['genre'],
					:bio => full_artist['bio'],
					:pop_id => full_artist['id'],
					:pop_likes => full_artist['likes'],
					:pop_link => full_artist['link'],
					:pop_source => "facebook"
				)
				new_artist.fb_picture = @graph.get_picture(full_artist['id'], :type => "large")
				new_artist.save
				puts "Successfully created new artist " + new_artist.name
			else
				puts "Updating existing artist " + search_artist.name
				if search_artist.description.blank?
					search_artist.description = full_artist['description']
				end
				if search_artist.bio.blank?
					search_artist.bio = full_artist['bio']
				end
				search_artist.website = full_artist['website']
				search_artist.genre = full_artist['genre']
				search_artist.pop_id = full_artist['id']
				search_artist.pop_likes = full_artist['likes']
				search_artist.pop_link = full_artist['link']
				search_artist.pop_source = "facebook"
				search_artist.fb_picture = @graph.get_picture(full_artist['id'], :type => "large")
				search_artist.save
				puts "Successfully updated artist " +  search_artist.name
			end
		end
	end



	desc "pull venues from apis"
	task :get_venues => :environment do

		html_ent = HTMLEntities.new
		offset = 0
		begin
			apiURL = URI("http://events.austin360.com/search?rss=1&sort=1&st=venue&srss=100&city=Austin&ssi=" + offset.to_s)
			apiXML = Net::HTTP.get(apiURL)
			doc = Document.new(apiXML)
			stream_count = XPath.first( doc, "//stream_count").text
			
			offset += stream_count.to_i 
			if stream_count == "0"
				break
			end

			XPath.each( doc, "//item") do |item|
				if RawVenue.where(:raw_id => item.elements["xCal:x-calconnect-venue"].elements["xCal:x-calconnect-venue-id"].text).size > 0
					next
				end

				raw_venue = RawVenue.create({
				    :name => html_ent.decode(item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-venue-name"].text),
				   	# :description => html_ent.decode(item.elements["description"].text), 
				   	:url => html_ent.decode(item.elements["xCal:x-calconnect-venue"].elements["xCal:url"] ? item.elements["xCal:x-calconnect-venue"].elements["xCal:url"].text : nil),
				   	:address => html_ent.decode(item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-street"].text),
				   	:city => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-city"].text,
				    :state_code => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-region"].text,
				    :zip => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-postalcode"].text,
				    :latitude => item.elements["geo:lat"].text,
				    :longitude => item.elements["geo:long"].text,
				    :phone => html_ent.decode(item.elements["xCal:x-calconnect-venue"].elements["xCal:x-calconnect-tel"] ? item.elements["xCal:x-calconnect-venue"].elements["xCal:x-calconnect-tel"].text : nil),
				    :raw_id => item.elements["xCal:x-calconnect-venue"].elements["xCal:x-calconnect-venue-id"].text,
				    :from => "austin360"
				})
				puts raw_venue.name
			end
		end until false
	end

	desc "flag all old events as deleted"
	task :trim_events => :environment do
		RawEvent.where("start <= ? AND deleted IS NULL",DateTime.now).each do |o|
			o.deleted = true
			o.save
		end
	end
	 
	desc "pull events from apis"
	task :get_events, [:until_time]  => [:trim_events, :environment] do |t, args|
		d_until = args[:until_time] ? DateTime.parse(args[:until_time]) : DateTime.now.advance(:weeks => 1)

		puts "getting events before " + d_until.to_s

		html_ent = HTMLEntities.new
		offset = 0
		begin
			@breakout = false
			apiURL = URI("http://events.austin360.com/search?rss=1&sort=1&srss=100&city=Austin&ssi=" + offset.to_s)
			apiXML = Net::HTTP.get(apiURL)
			doc = Document.new(apiXML)
			stream_count = XPath.first( doc, "//stream_count").text
			
			offset += stream_count.to_i 
			if stream_count == "0"
				break
			end

			XPath.each( doc, "//item") do |item|
				from = item.elements["title"].text.index("Event:") + 7
				to = item.elements["title"].text.rindex(" at ") - 1
				d_start = item.elements["xCal:dtstart"].text ? DateTime.parse(item.elements["xCal:dtstart"].text) : nil
				d_end = item.elements["xCal:dtend"].text ? DateTime.parse(item.elements["xCal:dtend"].text) : nil

				puts "event from: " + d_start.to_s

				if(d_until && d_start && d_start > d_until)
					@breakout = true
					break
				elsif RawEvent.where(:raw_id => item.elements["id"].text).size > 0
					next
				end

				raw_venue = RawVenue.where(:raw_id => item.elements["xCal:x-calconnect-venue"].elements["xCal:x-calconnect-venue-id"].text, :from => "austin360").first

				raw_event = RawEvent.create({
					:title => html_ent.decode(item.elements["title"].text[from..to]),
				    :description => html_ent.decode(item.elements["description"].text),
				    :start => d_start,
				    :end => d_end,
				    :latitude => item.elements["geo:lat"].text,
				    :longitude => item.elements["geo:long"].text,
				    :venue_name => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-venue-name"].text,
				    :venue_address => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-street"].text,
				    :venue_city => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-city"].text,
				    :venue_state => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-region"].text,
				    :venue_zip => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-postalcode"].text,
				    :url => item.elements["link"].text,
				    :raw_id => item.elements["id"].text,
				    :from => "austin360",
				    :raw_venue_id => (raw_venue ? raw_venue.id : nil)
				})
			end
		end until @breakout
	end

	desc "pull events from api for a venue"
	task :get_venue_event, [:num_venues]  => [:environment] do |t, args|

		num_venues = args[:num_venues].to_s.empty? ? 1 : args[:num_venues].to_i

		@raw_venues = RawVenue.includes(:venue).where("events_url IS NOT NULL AND (last_visited IS NULL OR last_visited < '#{ (Date.today - 7).to_datetime }')").take(num_venues)

		# pp @raw_venues

		html_ent = HTMLEntities.new

		@raw_venues.each do |raw_venue|
			puts raw_venue.venue.name
			apiURL = URI(raw_venue.events_url)
			apiXML = Net::HTTP.get(apiURL)
			doc = Document.new(apiXML)	
			XPath.each( doc, "//event") do |item|

				if RawEvent.where(:raw_id => item.elements["event_id"].text, :from => "do512").size > 0
					next
				end

				raw_event = RawEvent.create({
					:title => Sanitize.clean(html_ent.decode(item.elements["title"].text)),
				    :description => Sanitize.clean(html_ent.decode(item.elements["description"].text)),
				    :start => DateTime.parse(item.elements["begin_time"].text),
				    :url => item.elements["link"].text,
				    :raw_id => item.elements["event_id"].text,
				    :from => "do512",
				    :raw_venue_id => raw_venue.id
				})
			end
			raw_venue.last_visited = DateTime.now
			raw_venue.save
		end
	end
end