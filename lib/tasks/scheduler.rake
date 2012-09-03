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
			if (!occurrence.recurrence.gen_occurrences(1) && occurrence.recurrence.occurrences.count == 1)
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
				if RawVenue.where(:raw_id => item.elements["xCal:x-calconnect-venue"].elements["xCal:x-calconnect-venue-id"].text).count > 0
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
				elsif RawEvent.where(:raw_id => item.elements["id"].text).count > 0
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
		num_venues = args[:num_venues] || 1

		@raw_venues = RawVenue.includes(:venue).where("events_url IS NOT NULL AND (last_visited IS NULL OR last_visited < '#{ (Date.today - 7).to_datetime }')").take(num_venues)

		# pp @raw_venues

		html_ent = HTMLEntities.new

		@raw_venues.each do |raw_venue|
			puts raw_venue.venue.name
			apiURL = URI(raw_venue.events_url)
			apiXML = Net::HTTP.get(apiURL)
			doc = Document.new(apiXML)	
			XPath.each( doc, "//event") do |item|

				if RawEvent.where(:raw_id => item.elements["event_id"].text, :from => "do512").count > 0
					next
				end

				raw_event = RawEvent.create({
					:title => html_ent.decode(item.elements["title"].text),
				    :description => Sanitize.clean(html_ent.decode(item.elements["description"].text)),
				    :start => DateTime.parse(item.elements["begin_time"].text),
				    :url => item.elements["link"].text,
				    :raw_id => item.elements["event_id"].text,
				    :from => "do512",
				    :raw_venue_id => raw_venue.id
				})

				# pp raw_event
			end
			raw_venue.last_visited = DateTime.now
			raw_venue.save
		end
	end

end