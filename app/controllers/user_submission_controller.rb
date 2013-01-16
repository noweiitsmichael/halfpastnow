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
		@event.title = params[:new_title]
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
			search_match_arr.push("(venues.name ILIKE '%#{word}%' OR events.description ILIKE '%#{word}%' OR events.title ILIKE '%#{word}%' OR acts.name ILIKE '%#{word}%')")
		
			end

			search_match = search_match_arr * " AND "

			query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id FROM occurrences
					INNER JOIN events ON occurrences.event_id = events.id
		         	INNER JOIN venues ON events.venue_id = venues.id
                    LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                    LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
		         		WHERE #{search_match} AND occurrences.deleted != true
		         		ORDER BY events.id, occurrences.start LIMIT 20"

		    @occurrence_ids = ActiveRecord::Base.connection.select_all(query).collect { |e| e["occurrence_id"].to_i }
		    @occurrences = Occurrence.find(@occurrence_ids)

		    respond_to do |format|
		    	format.json { render json: @occurrences.to_json(:include => {:event => {:include => [:venue, :acts] }})}
		    end
	    end

	    
	end
end