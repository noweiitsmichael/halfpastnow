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

namespace :test do 
	desc "advance timestamps of events' occurrences"
	task :backtrack => :environment do
		Occurrence.all.each do |occurrence| 
			occurrence.start = occurrence.start.months_ago(4)
			if(occurrence.end)
				occurrence.end = occurrence.end.months_ago(4)
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
		BookmarkList.where(:featured => true).each do |bl|
			unless (bl.id == 99) || (bl.id == 101)
				puts "Bumping all events bookmarked under #{bl.name}"
				bl.bookmarks.each do |b|
					if b.bookmarked_type == "Occurrence"
						unless Occurrence.where(:id => b.bookmarked_id).empty?
							e = Occurrence.find(b.bookmarked_id).event
							if e.clicks < 300
								e.clicks = e.clicks + 200
								e.save!
							end
						end
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
				if e.clicks < 300
					e.clicks = e.clicks + 200
					e.save!
				end
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


		a = 100;
		if a == (1 || 2 || 3 || 4 || 5 || 6 || 100 || 34)
			puts "hi"
		else
			puts "nope"
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

desc "Send weekly_email"
task :send_emails => :environment do
	puts "send_emails"
	emails = Email.all
	emails.each{|e|
		UserMailer.weekly_email(e.email).deliver
    }
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

	desc "Eventbrite"
	task :get_eventbrite_events => :environment do
		# SXSW events in Austin from 3/07 to 3/18
		rawdata = Net::HTTP.get(URI.parse('http://www.eventbrite.com/json/event_search?app_key=QRZVIYQZFUIDXQ6Z4P&city=austin'))
		eb = JSON.parse(rawdata)
		puts "Total results: #{eb["events"][0]["summary"]["total_items"]}"
		pages = (eb["events"][0]["summary"]["total_items"] / 10).ceil
		puts "Pages: #{pages}"
		new_raw_venues = 0
		old_events = 0
		new_real_venues = 0
		new_events = 0
		updated_events = 0
		for i in 1..pages # each page, 10 results per page
			puts i
			sauce = "http://www.eventbrite.com/json/event_search?app_key=QRZVIYQZFUIDXQ6Z4P&city=austin&page=#{i}"
			# puts sauce
			rawdata = Net::HTTP.get(URI.parse(sauce))
			eb = JSON.parse(rawdata)
			for i in 1..10 #each result, 10 results per page
				# First resolve venue
				# If no existing raw venue is found via name and from Eventbrite, create one.
				raw_venue = nil
				if RawVenue.find(:first, :conditions =>[ "lower(name) = ?", eb["events"][i]["event"]["venue"]["name"].downcase ]) == nil
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
							if Venue.find(:first, :conditions => [ "lower(regexp_replace(address, '[^0-9a-zA-Z ]', '', 'g')) = ?", eb["events"][i]["event"]["venue"]["address"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
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
								real_venue = Venue.find(:first, :conditions => [ "lower(regexp_replace(address, '[^0-9a-zA-Z ]', '', 'g')) = ?", eb["events"][i]["event"]["venue"]["address"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]).id
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

				raw_venue = RawVenue.find(:first, :conditions =>[ "lower(name) = ?", eb["events"][i]["event"]["venue"]["name"].downcase ])
				puts "Associating event to #{raw_venue.name}"

				if RawEvent.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '', 'g')) = ?", new_e["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) != nil
					puts "...Skipping cuz already in rawevents queue"
					old_events += 1
					next
				end

				if Event.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '', 'g')) = ?", new_e["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ]) == nil
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
					sxsw_event = Event.find(:first, :conditions => [ "lower(regexp_replace(title, '[^0-9a-zA-Z ]', '', 'g')) = ?", new_e["name"].gsub(/[^0-9a-zA-Z ]/, '').downcase ])
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
					unless new_e["picture"].nil?
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
		end
		puts "Completed! Summary:"
		puts "New Raw Venues Created: #{new_raw_venues}"
		puts "New Actual Venues Created: #{new_real_venues}"
		puts "New Events Created: #{new_events}"
		puts "Existing events updated: #{updated_events}"
	end

	desc "Active.com"
	task :get_active_events => :environment do
		active_api_string = "http://api.amp.active.com/search/?f=activities&v=xml&k=&l=Austin%2C+TX%2C+US&r=25&m=meta%3AendDate%3Adaterange%3Atoday..+meta%3AsplitMediaType%3DEvent&s=date_asc&num=200&page=1&api_key=H8NUBG72ZJ56A9CD9QAY6FPE"
		doc = Nokogiri::XML(open(active_api_string))
		doc.xpath('//result').each do |item|
			puts item.elements["assetName"]
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
		d_until = args[:until_time] ? DateTime.parse(args[:until_time]) : DateTime.now.advance(:weeks => 4)
		new_events = 0;
		existing_events = 0;
		puts "getting events before " + d_until.to_s

		html_ent = HTMLEntities.new
		offset = 100
		begin
			@breakout = false
			apiURL = URI("http://events.austin360.com/search?city=Austin&new=n&rss=1&sort=1&srad=40.0&srss=100&st=event&swhat=&swhen=&swhere=Austin%2C+TX&ssi=" + offset.to_s)
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
				elsif RawEvent.where(:raw_id => item.elements["id"].text, :from => "austin360").size > 0
					puts "Found event #{RawEvent.where(:raw_id => item.elements["id"].text, :from => "austin360").first.title}"
					existing_events += 1
					next
				end

				raw_venue = RawVenue.where(:raw_id => item.elements["xCal:x-calconnect-venue"].elements["xCal:x-calconnect-venue-id"].text, :from => "austin360").first

				puts "Creating event #{html_ent.decode(item.elements["title"].text[from..to])}"
				raw_event = RawEvent.create({
					:title => html_ent.decode(item.elements["title"].text.match(/(?<=Event: )(.*)(?=, (Mon|Tue|Wed|Thu|Fri|Sat|Sun))/).to_s),
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
				new_events += 1
			end
		end until @breakout
		puts "TOTAL RAW EVENTS ADDED: #{new_events}"
		puts "Existing events found: #{existing_events}"
	end

	desc "pull events from api for a venue"
	task :get_venue_event, [:num_venues]  => [:environment] do |t, args|
		puts "Execute..."
		num_venues = args[:num_venues].to_s.empty? ? 1 : args[:num_venues].to_i

		@raw_venues = RawVenue.includes(:venue).where("events_url IS NOT NULL AND (last_visited IS NULL OR last_visited < '#{ (Date.today - 7).to_datetime }')").take(num_venues)

		# pp @raw_venues

		html_ent = HTMLEntities.new

		@raw_venues.each do |raw_venue|
			puts "Getting events for #{raw_venue.name}"
			if raw_venue.events_url.match(/^http/)
				apiURL = URI(raw_venue.events_url)
			else
				apiURL = URI("http://www.do512.com/venue/" + raw_venue.events_url + "?format=xml")
			end
			# apiURL = "http://www.do512.com/venue/#{apiURL}?format=xml"
			puts apiURL
			# apiXML = Net::HTTP.get(apiURL)
			# doc = Document.new(apiXML)	
			doc = Nokogiri::XML(open(apiURL))
			doc.xpath('//event').each do |item|
				if RawEvent.where(:raw_id => item.xpath("event_id").inner_text, :from => "do512").size > 0
					puts "Found event #{RawEvent.where(:raw_id => item.xpath("event_id").inner_text, :from => "do512").first.title}"
					next
				end

				puts "Creating event #{item.xpath("title").inner_text}"
				raw_event = RawEvent.create({
					:title => Sanitize.clean(html_ent.decode(item.xpath("title").inner_text)),
				    :description => Sanitize.clean(html_ent.decode(item.xpath("description").inner_text)),
				    :start => DateTime.parse(item.xpath("begin_time").inner_text),
				    :url => item.xpath("link").inner_text,
				    :raw_id => item.xpath("event_id").inner_text,
				    :from => "do512",
				    :raw_venue_id => raw_venue.id
				})

				if item.xpath("image").inner_text
					cover_i = Picture.create(:pictureable_id => raw_event.id, :pictureable_type => "RawEvent", 
							   	   :image => open(item.xpath("image").inner_text)) rescue nil
					if cover_i
						raw_event.cover_image = cover_i.id
						raw_event.cover_image_url = cover_i.image_url(:cover).to_s
						raw_event.save!
					end
				end
			end
			raw_venue.last_visited = DateTime.now
			raw_venue.save
		end
	end
end

