class UserSubmissionController < ApplicationController
helper :content

	def eventSearch
	end

	def eventEdit1
		@event = Event.find(params[:id])
    	@parentTags = Tag.includes(:parentTag, :childTags).all.select{ |tag| tag.parentTag.nil? }
	end

	def eventCreate1
		@event = Event.new
    	@parentTags = Tag.includes(:parentTag, :childTags).all.select{ |tag| tag.parentTag.nil? }
    	pp @parentTags
		render "eventEdit1"
	end

	def eventSearchTerm
		if (params[:term].to_s.empty?)
			respond_to do |format|
		    	format.json { render json: [] }
		    end
		else
			search = params[:term].gsub(/[^0-9a-z ]/i, '').upcase
			searches = search.split(' ')

			search_match_arr = []
			searches.each do |word|
			search_match_arr.push("(upper(venues.name) LIKE '%#{word}%' OR upper(events.description) LIKE '%#{word}%' OR upper(events.title) LIKE '%#{word}%')")
			end

			search_match = search_match_arr * " AND "

			query = "SELECT events.id AS event_id FROM events
		         	INNER JOIN venues ON events.venue_id = venues.id
		         		WHERE #{search_match}"

		    @event_ids = ActiveRecord::Base.connection.select_all(query).collect { |e| e["event_id"] }

		    @events = Event.includes(:venue).find(@event_ids)

		    respond_to do |format|
		    	format.json { render json: @events.to_json(:include => :venue) }
		    end
	    end

	    
	end
end