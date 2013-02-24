require 'net/http'
require 'rexml/document'
require 'pp'
require 'htmlentities'
require 'rubygems'
require 'sanitize'
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


	desc "clearing dangling bookmarks and tags"
	task :scrub => :environment do
		puts "Scrubbing..."
		Bookmark.find_each do |b|
			if b.bookmarked_type == "Occurrence"
				if Occurrence.where(:id => b.bookmarked_id).empty?
					puts "Deleting #{b.bookmarked_type} #{b.bookmarked_id}"
					b.destroy
				end
			elsif b.bookmarked_type == "Act"
				if Act.where(:id => b.bookmarked_id).empty?
					puts "Deleting #{b.bookmarked_type} #{b.bookmarked_id}"
					b.destroy
				end
			elsif b.bookmarked_type == "Venue"
				if Venue.where(:id => b.bookmarked_id).empty?
					puts "Deleting #{b.bookmarked_type} #{b.bookmarked_id}"
					b.destroy
				end
			end
		end


		EventsTags.find_each do |t|
			if Event.where(:id => t.event_id).empty?
				puts "destroying event tag"
				EventsTags.delete_all(:event_id => t.event_id)
			end
		end

		ActsTags.find_each do |t|
			if Act.where(:id => t.act_id).empty?
				puts "destroying act tag"
				ActsTags.delete_all(:event_id => t.act_id)
			end
		end

		TagsVenues.find_each do |t|
			if Venue.where(:id => t.venue_id).empty?
				puts "destroying venue tag"
				TagsVenues.delete_all(:event_id => t.venue_id)
			end
		end
	end

	desc "Eliminating Duplicate Venues"

	#####
	# Next time, what might be faster is if you manually set all of the IDs and then run through it that way
	# Yea, that would be better. Cuz this still has about 15% that are not found.
	#
	#####
	task :duplicate_venues => :environment do
		puts "Opening file..."
		f = File.open(Rails.root + "app/_etc/duplicate_venues4.csv")
		lines = f.readlines
		lines.each do |oneVenue|
			otherVenues = oneVenue.split(/,/)
			finalVenueName = otherVenues[0].strip
			puts ""
			puts "Final Venue: #{finalVenueName}"
			finalVenue = Venue.find(:first, :conditions => [ 'lower(name) = ?', finalVenueName.downcase ])
			if finalVenue.nil?
				puts "------ No venue found for #{finalVenueName}"
				next
			end
			puts "Found it, working on #{finalVenueName}"
			otherVenues.slice!(0)
			otherVenues.delete("")
			otherVenues.delete("\n")
			puts "Consolidating to #{finalVenue.name} from:"
			pp otherVenues
			puts "Final Venue Original Num Events = #{finalVenue.events.count}"
			otherVenues.each do |ven|
				v = Venue.find(:first, :conditions => [ 'lower(name) = ? and id != ?', ven.downcase.strip, finalVenue.id ])
				if v.nil?
					puts "****************** No venue found for duplicate #{ven}"
					next
				else 
					puts "Found for duplicate #{ven}"
				end
				puts "...Working on duplicate #{v.name}"
				r = RawVenue.find(:first, :conditions => [ 'lower(name) = ?', v.name.downcase ])
				if r.nil?
					puts "*****************No venue found for raw venue #{v.name} WTF"
					next
				else
					puts "Venue found for raw venue #{v.name} WTF"
				end

				puts "Dupe Num Events = #{v.events.count}"
				v.events.each do |e|
					e.venue_id = finalVenue.id
					e.save!
				end
				puts "Successfully moved events from #{v.name} to #{finalVenue.name}"

				r.venue_id = finalVenue.id
				r.save!

				# have to reload v to remove events or else events will STILL get deleted
				toDelete = Venue.find(v.id)
				toDelete.destroy
				puts "Successfully destroyed"
				finalVenue = Venue.find(finalVenue.id)
				puts "FINAL VENUE NEW Num Events = #{finalVenue.events.count}"
			end
		end
	end

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
					if e.clicks < 200
						e.clicks = e.clicks + 100
						e.save!
					end
				end
			end
		end
	end

	desc "bumping up venues"
	task :venue_bump => :environment do

		# Venue.where(:id => [47138,41191,40284,47328,44340,39334,40488,43302,47267,42670,40459,39386,40238,40219,43604,43628,44687,39376,40345,40742,47242,39620,47239,47444,47141,47524,39438,46956,39337,41359,47269,40381,39424,47338,47325,40139,39528,43006,39346,39402,46974,43146,39593,41499,39391,41038,39562,42186,40823,47035,47717,46884,46885,44557,42217,44703,46951,41014,43860,39326,39382,39383,41150,41117,39338,39544,42388,42055,40239,39335,40201,47142,45251,41278,42219,39421,40226,42642,39359,44627,42040,41553,39353,41819,39712,40188,41412,40149,44453,39350,43277,42206,40564,47307,42989,39446,39362,39401,42871,40551,39399,42336,40041,39352,39735,39364,41615,40426,40820,41952,40464,44194,40556,40888,39435,44164,39473,41423,40977,47004,40523,41172,39645,45929,47487,47233,40462,41468,40358,41584,44101,47473,43596,43819,43005,41781,39430,41200,42892]).each do |v|
		# 	puts "#{v.name},#{v.id}"
		# 	v.events.each do |e|
		# 		if e.clicks < 100
		# 			e.clicks += 100
		# 			e.save!
		# 		end
		# 	end
		# end

		puts "Opening file..."
		f = File.open(Rails.root + "app/_etc/venue_bump.csv")
		lines = f.readlines
		lines.each do |oneVenue|
			oneVenue = oneVenue.split(/,/);
			v = Venue.find(oneVenue[1])
			puts "#{oneVenue[0]}, #{oneVenue[1]}"
			v.events.each do |e|
				e.clicks = e.clicks + 100
				e.save!
			end
		end
	end


	desc "migrate admin_owner to assigned_admin column"
	task :shift => :environment do
		Venue.find(:all).each do |v|
			if !v.admin_owner.nil?
				v.assigned_admin = v.admin_owner
				v.save!
			end
		end
		puts "done!"
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

	desc "Eventbrite SXSW"
	task :sxsw_eventbrite => :environment do
		# SXSW events in Austin from 3/07 to 3/18
		rawdata = Net::HTTP.get(URI.parse('http://www.eventbrite.com/json/event_search?app_key=QRZVIYQZFUIDXQ6Z4P&keywords=sxsw&city=austin&date=2013-03-07+2013-03-18'))
		eb = JSON.parse(rawdata)
		puts "Total results: #{eb["events"][0]["summary"]["total_items"]}"
		pages = (eb["events"][0]["summary"]["total_items"] / 10).ceil
		puts "Pages: #{pages}"
		new_raw_venues = 0
		new_real_venues = 0
		new_events = 0
		updated_events = 0
		for i in 1..pages # each page, 10 results per page
			puts i
			sauce = "http://www.eventbrite.com/json/event_search?app_key=QRZVIYQZFUIDXQ6Z4P&keywords=sxsw&city=austin&date=2013-03-07+2013-03-18&page=#{i}"
			puts sauce
			rawdata = Net::HTTP.get(URI.parse(sauce))
			eb = JSON.parse(rawdata)
			for i in 1..10 #each result, 10 results per page
				# First resolve venue
				# If no existing raw venue is found via name and from Eventbrite, create one.
				raw_venue = nil
				if RawVenue.find(:first, :conditions =>[ "lower(name) = ? AND from = 'eventbrite'", eb["events"][i]["event"]["venue"]["name"].downcase ]) == nil
						puts "!! Creating raw venue for #{eb["events"][i]["event"]["venue"]["name"]}"
						raw_venue = RawVenue.create!(
							:name => eb["events"][i]["event"]["venue"]["name"],
							:address => eb["events"][i]["event"]["venue"]["address"],
							:address2 => eb["events"][i]["event"]["venue"]["address_2"],
							:city => eb["events"][i]["event"]["venue"]["city"],
							:state_code => eb["events"][i]["event"]["venue"]["region"],
							:latitude => eb["events"][i]["event"]["venue"]["latitude"],
							:longitude => eb["events"][i]["event"]["venue"]["longitude"],
							:zip => eb["events"][i]["event"]["venue"]["postal_code"],
							:raw_id => eb["events"][i]["event"]["venue"]["id"],
							:from => "eventbrite"
						)
						new_raw_venues += 1
						# Now see if a real venue needs to be created
						if Venue.find(:first, :conditions => [ "lower(name) = ?", eb["events"][i]["event"]["venue"]["name"].downcase ]) == nil
							if Venue.find(:first, :conditions => [ "lower(regexp_replace(address, '[^0-9a-zA-Z ]', '')) = ?", eb["events"][i]["event"]["venue"]["address"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
								puts "!! Creating real venue for #{eb["events"][i]["event"]["venue"]["name"]}"
								new_venue = Venue.create!(
									:name => raw_venue.name,
									:address => raw_venue.address,
									:address2 => raw_venue.address2,
									:city => raw_venue.city,
									:state => raw_venue.state_code,
									:latitude => raw_venue.latitude,
									:longitude => raw_venue.longitude,
									:zip => raw_venue.zip
								)
								raw_venue.venue_id = new_venue.id
								raw_venue.save
								new_real_venues += 1
							else
								puts "....Found venue for #{eb["events"][i]["event"]["venue"]["name"]} by address"
								real_venue = Venue.find(:first, :conditions => [ "lower(regexp_replace(address, '[^0-9a-zA-Z ]', '')) = ?", eb["events"][i]["event"]["venue"]["address"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]).id
								raw_venue.venue_id = real_venue
								raw_venue.save
							end
						else
							puts "....Found venue for #{eb["events"][i]["event"]["venue"]["name"]} by name"
							real_venue = Venue.find(:first, :conditions => [ "lower(name) = ?", eb["events"][i]["event"]["venue"]["name"].downcase ]).id
							raw_venue.venue_id = real_venue
							raw_venue.save
						end
				else
					if eb["events"][i]["event"]["venue"]["name"] == ""
						puts "** Error, no venue name for Eventbrite event #{eb["events"][i]["event"]["id"]} #{eb["events"][i]["event"]["title"]}" 
						next
					end
					puts "....Found raw venue for #{eb["events"][i]["event"]["venue"]["name"]} by name"
				end
				#### Done with venue stuff, on to events ####

				new_e = Hash.new
				new_e["id"] = eb["events"][i]["event"]["id"]
				new_e["name"] = eb["events"][i]["event"]["title"]
				new_e["venue_id"] = eb["events"][i]["event"]["venue"]["id"]
				new_e["start_time"] = eb["events"][i]["event"]["start_date"]
				new_e["end_time"] = eb["events"][i]["event"]["end_date"]
				new_e["description"] = eb["events"][i]["event"]["description"]
				new_e["picture"] = eb["events"][i]["event"]["logo"]
				new_e["ticketing"] = eb["events"][i]["event"]["url"]

				raw_venue = RawVenue.find(:first, :conditions =>[ "lower(name) = ? AND from = 'eventbrite'", eb["events"][i]["event"]["venue"]["name"].downcase ])
				puts "Associating event to #{raw_venue.name}"

				if Event.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '')) = ?", new_e["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
					puts "....Creating event #{new_e["name"]}"
					sxsw_event = RawEvent.create!(
									:title => new_e["name"],
									:description => new_e["description"],
									:event_url => new_e["ticketing"],
									:ticket_url => new_e["ticketing"],
									:url => new_e["ticketing"],
									:start => new_e["start_time"],
									:end => new_e["end_time"],
									:raw_id => new_e["id"],
									:from => "eventbrite",
									:raw_venue_id => raw_venue.id
									)
					new_events += 1
					cover_i = Picture.create(:pictureable_id => sxsw_event.id, :pictureable_type => "RawEvent", 
							   	   :image => open(new_e["picture"])) rescue nil
					if cover_i
						sxsw_event.cover_image = cover_i.id
						sxsw_event.cover_image_url = cover_i.image_url(:cover).to_s
						sxsw_event.save!
					end
				else
					puts "....Updating Event #{new_e["name"]}"
					sxsw_event = Event.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '')) = ?", new_e["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ])
					sxsw_event.title = new_e["name"]
					sxsw_event.description = new_e["description"]
					sxsw_event.venue_id = raw_venue.venue_id
					sxsw_event.save!
					occ = sxsw_event.occurrences.first
					occ.start = new_e["start_time"]
					occ.end = new_e["end_time"]
					occ.event_id = sxsw_event.id
					# y occ
					occ.save!
					updated_events += 1
					# # Create pictures
					if Picture.where(:pictureable_type => "Event", :pictureable_id => sxsw_event.id).count <= 2
						cover_i = Picture.create(:pictureable_id => sxsw_event.id, :pictureable_type => "Event", 
								   	   :image => open(new_e["picture"]))
						sxsw_event.cover_image = cover_i.id
						sxsw_event.cover_image_url = cover_i.image_url(:cover).to_s
						sxsw_event.save!
					end
				end
			end
		end
		puts "Completed! Summary:"
		puts "New Raw Venues Created: #{new_raw_venues}"
		puts "New Actual Venues Created: #{new_real_venues}"
		puts "New Events Created: #{new_events}"
		puts "Existing events updated: #{updated_events}"
	end

	desc "do512 SXSW artists"
	task :do512_sxsw_artists => :environment do
		puts "Opening artists file..."
		f = File.open(Rails.root + "app/_etc/artist.csv")
		lines = f.readlines
		puts "Total artists: #{lines.count}"
		new_artists = 0;
		old_artists = 0;
		lines.each_with_index do |l, index|
			lines[index] = l.split(/","/)
			if Act.find(:first, :conditions => [ "lower(regexp_replace(name, '[^0-9a-zA-Z ]', '')) = ?", lines[index][1].gsub(/[^0-9a-zA-Z ]/, '').downcase ])
				old_artists += 1
			else
				new_artists += 1
				puts lines[index][1]
			end
		end

		puts "#{new_artists} new artists, #{old_artists} old artists"
	end

	desc "do512 SXSW events"
	task :do512_sxsw_events => :environment do
		puts "Opening events file..."
		f = File.open(Rails.root + "app/_etc/do512_oo.csv")
		lines = f.readlines
		puts "Total events: #{lines.count}"
		new_events = 0;
		old_events = 0;
		lines.each_with_index do |l, index|
			lines[index] = l.split(/","/)
			if Event.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '')) = ?", lines[index][1].gsub(/[^0-9a-zA-Z ]/, '').downcase ])
				old_events += 1
			else
				new_events += 1
				puts lines[index][1]
			end
		end

		puts "#{new_events} new events, #{old_events} old events"
	end

	desc "SXSW venues"
	task :sxsw_venues => :environment do
		puts "Opening venues file..."
		f = File.open(Rails.root + "app/_etc/sxsw_venues.csv")
		lines = f.readlines
		lines.each_with_index do |l, index|
			lines[index] = l.split(/","/)
			lines[index][0] = (lines[index][0].split(/"/))[1] # because there's an extra "/" in there for some reason
			new_hash = Hash.new
			new_hash["id"] = lines[index][0]
			new_hash["name"] = lines[index][1]
			new_hash["street"] = lines[index][3]
			new_hash["city"] = lines[index][4]
			new_hash["state"] = lines[index][5]
			new_hash["lat"] = lines[index][8]
			new_hash["long"] = lines[index][9]
			new_hash["picture"] = lines[index][11]
			new_hash["parent_id"] = lines[index][23]
			new_hash["super_parent_id"] = lines[index][24]
			lines[index] = new_hash
		end

		# iterate through lines, whenever come across valid venue_main_ref, find that serial and save that venue
		# gotta split these out so that parent venues are done first
		lines.each do |line|
			if !line["super_parent_id"].blank?
				super_parent = lines.detect {|f| f["id"] == line["super_parent_id"] }
				sxswVenueSave(line, super_parent)
			end
		end
		#do it again for parent_refs
		lines.each do |line|
			if line["super_parent_id"].blank? && line["parent_id"] != "0"
				parent = lines.detect {|f| f["id"] == line["parent_id"] }
				sxswVenueSave(line, parent)
			end
		end
		#do it again for the rest
		lines.each do |line|
			if line["parent_id"] == "0"
				sxswVenueSave(line, line)
			end
		end
		f.close
	end

	desc "SXSW artists"
	task :sxsw_artists => :environment do
		# first create list of artist id's from events
		artist_list = Array.new
		count = 0
		puts "Creating artist list from events file..."
		f = File.open(Rails.root + "app/_etc/sxsw_events.csv")
		lines = f.read
		lines = lines.split(/0"\n/)
		lines.each do |l|
			l = l.split(/","/)
			if (l[37] == "Music") && (!l[38].blank?) && (l[42] == "Showcase")
				artist = Hash.new
				artist["id"] = l[38]
				artist["genre"] = l[43]
				artist_list << artist
			end
		end
		puts "length: #{artist_list.length}"

		# create list of all artists
		puts "Opening artists file..."
		f = File.open(Rails.root + "app/_etc/sxsw_acts.csv")
		lines = f.read
		lines = lines.split(/"\n/)
		lines.each_with_index do |l, index|
			lines[index] = l.split(/","/)			
			lines[index][0] = (lines[index][0].split(/"/))[1] # because there's an extra " in there
			new_hash = Hash.new
			new_hash["id"] = lines[index][14]
			new_hash["name"] = lines[index][3]
			new_hash["subtitle"] = lines[index][5]
			new_hash["description"] = lines[index][6]
			new_hash["website"] = lines[index][9]
			new_hash["embed"] = lines[index][10]
			new_hash["picture"] = lines[index][8]
			lines[index] = new_hash
		end

		artist_list.each do |artist|
			matched_artist = lines.detect {|f| f["id"] == artist["id"] }
			artist["name"] = matched_artist["name"]
			artist["subtitle"] = matched_artist["subtitle"]
			desc_only = /.+Description<\/strong><br \/>(.+?)<br \/>.+/m.match(matched_artist["description"])
			if !desc_only.nil?
				artist["description"] = desc_only[1]
			else
				artist["description"] = artist["subtitle"]
			end

			website = /.+Website<\/strong><br \/><a href='(.+?)' target='_blank'>.+/.match(matched_artist["description"])
			if !website.nil?
				artist["website"] = website[1]
			else
				artist["website"] = nil
			end
			artist["embed"] = matched_artist["embed"]
			artist["picture"] = matched_artist["picture"]

			# now hit database and find or create a new artist
			if Act.find(:first, :conditions => [ "lower(regexp_replace(name, '[^0-9a-zA-Z ]', '')) = ?", artist["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
				puts "...Creating new artist for #{artist["name"]}"
				act_edit = Act.create!(
							:name => artist["name"],
							:description => artist["description"],
							:website => artist["website"],
							:pop_id => artist["id"],
							:pop_source => "sxsw"
						)
				act_edit.save

				# Create picture
				puts "Saving picture...."
				Picture.create(:pictureable_id => act_edit.id, :pictureable_type => "Act", 
						   	   :image => open(artist["picture"])) rescue nil

				# Creating Tags
				puts "Saving tags..."
				ActsTags.create(:act_id => act_edit.id, :tag_id => 1)
				sxswTagCreate(act_edit.id, artist["genre"])

				# Creating Embed
				puts "Saving embed..."
				if (artist["embed"] != nil) && (!artist["embed"].blank?)
					artist["embed"] = /.+?v=(.+?)\Z/.match(artist["embed"])[1]
					embed_code = '<iframe width="100%" height="280" src="http://www.youtube.com/embed/' + 
								 artist["embed"] + '" frameborder="0" allowfullscreen></iframe>';
					Embed.create!(:embedable_id => act_edit.id, :primary => true, :source => embed_code, :embedable_type => "Act")
				end

				count += 1
			else
				act_edit = Act.find(:first, :conditions => [ "lower(regexp_replace(name, '[^0-9a-zA-Z ]', '')) = ?", artist["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ])
				puts "...Found existing artist #{act_edit.name}"
				act_edit.pop_source = "sxsw"
				act_edit.pop_id = artist["id"]
				act_edit.save!
			end
		end
		puts "Created #{count} new artists out of #{artist_list.length} artists"
	end

	desc "SXSW events"
	task :sxsw_events => :environment do
		count = 0
		puts "Creating events from file..."
		f = File.open(Rails.root + "app/_etc/sxsw_events.csv")
		lines = f.read
		lines = lines.split(/0"\n/)
		lines.each do |e|
			e = e.split(/","/)
			e[0] = (e[0].split(/"/))[1] # because there's an extra " in there
			# y e
			new_e = Hash.new
			new_e["id"] = e[0]
			new_e["name"] = e[1]
			new_e["venue_id"] = e[3]
			new_e["start_time"] = e[4]
			new_e["end_time"] = e[5]
			desc_only = /.+Description<\/strong><br \/>(.+?)<br \/>.+/m.match(e[12])
			if !desc_only.nil?
				new_e["description"] = e[23] + "\n\n" + desc_only[1]
			else
				new_e["description"] = new_e["subtitle"]
			end
			new_e["picture"] = e[11]
			new_e["subtitle"] = e[23]
			new_e["conference"] = e[37]
			new_e["artist"] = e[38]
			new_e["type"] = e[42]
			# y new_e
			new_e_venue = RawVenue.where(:from => "sxsw", :raw_id => new_e["venue_id"]).first.venue_id

			if Event.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '')) = ?", new_e["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
				puts "....Creating event #{new_e["name"]}"
				sxsw_event = Event.create!(
								:title => new_e["name"],
								:description => new_e["description"],
								:venue_id => new_e_venue
								)

				Occurrence.create(
					:start => new_e["start_time"],
					:end => new_e["end_time"],
					:event_id => sxsw_event.id
					)

				EventsTags.create(:event_id => sxsw_event.id, :tag_id => 163)
				if new_e["type"] == "Showcase"
					event_act = Act.where(:pop_source => "sxsw", :pop_id => new_e["artist"]).first
					ActsEvents.create(:act_id => event_act.id, :event_id => sxsw_event.id) rescue puts "!!!!!! FAILED TO LINK ACT AND EVENT"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 1)
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 168)
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 185)
				elsif new_e["type"] == "Screening"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 186)
				elsif new_e["type"] == "Sessions"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 187)
				elsif new_e["type"] == "Party"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 184)
				elsif new_e["type"] == "Special Event"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 188)
				end

				if new_e["conference"] == "Music"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 179)
				elsif new_e["conference"] == "Interactive"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 176)
				elsif new_e["conference"] == "Film"
					EventsTags.create(:event_id => sxsw_event.id, :tag_id => 183)
				end
						

				puts "Saving picture...."
				cover_i = Picture.create(:pictureable_id => sxsw_event.id, :pictureable_type => "Event", 
						   	   :image => open(new_e["picture"]))
				sxsw_event.cover_image = cover_i.id
				sxsw_event.cover_image_url = cover_i.image_url(:cover).to_s
				sxsw_event.save!

			else
				puts "....Updating Event #{new_e["name"]}"
				sxsw_event = Event.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '')) = ?", new_e["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ])
				sxsw_event.title = new_e["name"]
				sxsw_event.description = new_e["description"]
				sxsw_event.venue_id = new_e_venue
				sxsw_event.save!
				occ = sxsw_event.occurrences.first
				occ.start = new_e["start_time"]
				occ.end = new_e["end_time"]
				occ.event_id = sxsw_event.id
				# y occ
				occ.save!

				# Create pictures
				if Picture.where(:pictureable_type => "Event", :pictureable_id => sxsw_event.id).count <= 2
					puts "Saving picture...."
					cover_i = Picture.create(:pictureable_id => sxsw_event.id, :pictureable_type => "Event", 
							   	   :image => open(new_e["picture"]))
					sxsw_event.cover_image = cover_i.id
					sxsw_event.cover_image_url = cover_i.image_url(:cover).to_s
					sxsw_event.save!

				end
			end


		end

	end

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

def sxswVenueSave(line, parent)
	if RawVenue.find(:first, :conditions => ["lower(regexp_replace(name, '[^0-9a-zA-Z ]', '')) = ?", line["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
		if RawVenue.find(:first, :conditions => [ "lower(regexp_replace(address, '[^0-9a-zA-Z ]', '')) = ?", line["street"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
			puts "Creating raw venue for #{line["name"]}"
			raw_venue = RawVenue.create!(
				:name => line["name"],
				:address => line["street"],
				:city => line["city"],
				:state_code => line["state"],
				:latitude => line["lat"],
				:longitude => line["long"],
				:raw_id => line["id"],
				:from => "sxsw"
			)
		else
			return
		end
	else
		return
	end

	if line["name"] == "Venue TBA"
		new_venue = Venue.create!(
			:name => raw_venue.name,
			:latitude => raw_venue.latitude,
			:longitude => raw_venue.longitude
		)
		raw_venue.venue_id = new_venue.id
		raw_venue.save
	elsif Venue.find(:first, :conditions => [ "lower(name) = ?", parent["name"].downcase ]) == nil
		if Venue.find(:first, :conditions => [ "lower(regexp_replace(address, '[^0-9a-zA-Z ]', '')) = ?", parent["street"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
			puts "....Creating real venue for #{line["name"]}"
			new_venue = Venue.create!(
				:name => raw_venue.name,
				:address => raw_venue.address,
				:city => raw_venue.city,
				:state => raw_venue.state_code,
				:latitude => raw_venue.latitude,
				:longitude => raw_venue.longitude
			)
			raw_venue.venue_id = new_venue.id
			raw_venue.save

			# # Create pictures
			puts "Saving picture...."
			Picture.create(:pictureable_id => new_venue.id, :pictureable_type => "Venue", 
					   	   :image => open(line["picture"])) rescue nil
		else
			puts "Found venue for #{parent["name"]} by address via #{line["name"]}"
			real_venue = Venue.find(:first, :conditions => [ "lower(regexp_replace(address, '[^0-9a-zA-Z ]', '')) = ?", parent["street"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]).id
			raw_venue.venue_id = real_venue
			raw_venue.save
			# # Create pictures
			if Picture.where(:pictureable_type => "Venue", :pictureable_id => real_venue).count <= 3
				puts "Saving picture...."
				Picture.create(:pictureable_id => real_venue, :pictureable_type => "Venue", 
						   	   :image => open(line["picture"])) rescue nil
			end
		end
	else
		puts "Found venue for #{parent["name"]} by name via #{line["name"]}"
		real_venue = Venue.find(:first, :conditions => [ "lower(name) = ?", parent["name"].downcase ]).id
		raw_venue.venue_id = real_venue
		raw_venue.save
		# # Create pictures
		if Picture.where(:pictureable_type => "Venue", :pictureable_id => real_venue).count <= 3
			puts "Saving picture...."
			Picture.create(:pictureable_id => real_venue, :pictureable_type => "Venue", 
					   	   :image => open(line["picture"])) rescue nil
		end
	end
end

def sxswTagCreate(act_id, tag_name)
	ActsTags.create!(:act_id =>act_id, :tag_id =>161)
	case tag_name
	when "Alt Country"
		ActsTags.create!(:act_id =>act_id, :tag_id =>4)
	when "Americana"
		ActsTags.create!(:act_id =>act_id, :tag_id =>100)
	when "Avant/Experimental"
		ActsTags.create!(:act_id =>act_id, :tag_id =>98)
	when "Bluegrass"
		ActsTags.create!(:act_id =>act_id, :tag_id =>39)
	when "Blues"
		ActsTags.create!(:act_id =>act_id, :tag_id =>40)
	when "Classical"
		ActsTags.create!(:act_id =>act_id, :tag_id =>74)
	when "Comedy"
		ActsTags.create!(:act_id =>act_id, :tag_id =>32)
	when "Country"
		ActsTags.create!(:act_id =>act_id, :tag_id =>4)
	when "DJ"
		ActsTags.create!(:act_id =>act_id, :tag_id =>64)
	when "Dance"
		ActsTags.create!(:act_id =>act_id, :tag_id =>37)
	when "Electronic"
		ActsTags.create!(:act_id =>act_id, :tag_id =>37)
	when "Folk"
		ActsTags.create!(:act_id =>act_id, :tag_id =>41)
	when "Funk"
		ActsTags.create!(:act_id =>act_id, :tag_id =>73)
	when "Gospel"
		ActsTags.create!(:act_id =>act_id, :tag_id =>102)
	when "Hip-Hop/Rap"
		ActsTags.create!(:act_id =>act_id, :tag_id =>93)
		ActsTags.create!(:act_id =>act_id, :tag_id =>8)
	when "Jazz"
		ActsTags.create!(:act_id =>act_id, :tag_id =>7)
	when "Latin Rock"
		ActsTags.create!(:act_id =>act_id, :tag_id =>36)
	when "Metal"
		ActsTags.create!(:act_id =>act_id, :tag_id =>9)
	when "Pop"
		ActsTags.create!(:act_id =>act_id, :tag_id =>35)
	when "Punk"
		ActsTags.create!(:act_id =>act_id, :tag_id =>3)
	when "R & B"
		ActsTags.create!(:act_id =>act_id, :tag_id =>34)
	when "R&B"
		ActsTags.create!(:act_id =>act_id, :tag_id =>34)
	when "Reggae"
		ActsTags.create!(:act_id =>act_id, :tag_id =>42)
	when "Rock"
		ActsTags.create!(:act_id =>act_id, :tag_id =>2)
	when "Singer-Songwriter"
		ActsTags.create!(:act_id =>act_id, :tag_id =>99)
	when "Ska"
		ActsTags.create!(:act_id =>act_id, :tag_id =>101)
	when "Spoken Word"
		ActsTags.create!(:act_id =>act_id, :tag_id =>99)
	when "Tejano"
		ActsTags.create!(:act_id =>act_id, :tag_id =>36)
	when "World"
		ActsTags.create!(:act_id =>act_id, :tag_id =>33)
	end
end
