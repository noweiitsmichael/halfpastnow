require 'net/http'
require 'rexml/document'
require 'pp'
require 'htmlentities'
require 'rubygems'
require 'sanitize'
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

	desc "pull venues from facebook events"
	task :get_fb_events => :environment do
		access_token = User.find_by_email("noweiitsmichael@yahoo.com").fb_access_token
		puts "Pulling from Facebook. IS IT DAYLIGHT SAVINGS TIME YET?!?!?!?!?!?!?!"
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
						event.start = event.start.to_datetime + 1.hours
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
					:fb_id => full_artist['id'],
					:fb_likes => full_artist['likes'],
					:fb_link => full_artist['link'],
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
				search_artist.fb_id = full_artist['id']
				search_artist.fb_likes = full_artist['likes']
				search_artist.fb_link = full_artist['link']
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