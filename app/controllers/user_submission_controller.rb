class UserSubmissionController < ApplicationController
helper :content

	def eventCreate1
		authorize! :eventSubmit1, @user, :message => 'Please log in to add events.'
		@event = Event.new
		@event.title = params[:new_title]
    	@parentTags = Tag.includes(:parentTag, :childTags).all.select{ |tag| tag.parentTag.nil? }
    	# pp @parentTags
		render "eventEdit1"
	end

	def eventEdit1
		@event = Event.find(params[:id])
    	@parentTags = Tag.includes(:parentTag, :childTags).all.select{ |tag| tag.parentTag.nil? }
	end

	def eventEdit2
		@event = Event.find(params[:id])
	end

	def eventSubmit1
		authorize! :eventSubmit1, @user, :message => 'Please log in to add events.'

		if !params[:event][:id].to_s.empty?
			@event = Event.find(params[:event][:id])
		else
			@event = Event.new
		end
		
	    params[:event][:user_id] = current_user.id
	    params[:event][:occurrences_attributes].select! { |k,v| !v["start"].blank? || ( !v["id"].blank? && v["deleted"] == "1") }
	    params[:event][:recurrences_attributes].select! { |k,v| !v["start"].blank? || ( !v["id"].blank? && v["_destroy"] == "1") }
	    params[:event][:act_ids].select! { |a| a != "0" }

	    # pp params[:event][:occurrences_attributes]

	    @event.update_attributes!(params[:event])
	    @event.completion = @event.completedness
	    @event.save!
        @event.occurrences.each do |occ|
      	  occ.slug = "#{occ.event.title.truncate(40)}-at-#{occ.event.venue.name.truncate(40)}" rescue "#{occ.id}"
	      occ.save
	    end
	    redirect_to :action => :eventEdit2, :id => @event.id
	end

	def eventSubmit2
		authorize! :eventSubmit1, @user, :message => 'Please log in to add events.'
		@event = Event.find(params[:event][:id])

	    @event.update_attributes!(params[:event])
	    @event.completion = @event.completedness
	    @event.save!

	    unless params[:pictures].nil? 
	      params[:pictures].each do |pic|
	          addedPic = Picture.find(pic[1]["id"])
	          addedPic.pictureable_id = @event.id
	          addedPic.save!
	      end
	    end

	end

	def eventSearch
	end

	def actCreate
		@act = Act.new
		@act.name = params[:new_name]
    	@parentTags = Tag.includes(:parentTag, :childTags).all.select{ |tag| tag.parentTag.nil? }
		# pp @act
		render "actEdit"
	end

	def actEdit
		@act = Act.find(params[:id])
    	@parentTags = Tag.includes(:parentTag, :childTags).all.select{ |tag| tag.parentTag.nil? }
	end

	def actSubmit
		pp params

		if !params[:act][:id].to_s.empty?
			@act = Act.find(params[:act][:id])
		else
			@act = Act.new
		end
	    
	    params[:act][:embeds_attributes].select! { |k,v| !v["source"].blank? || !v["_destroy"].blank? }

	    @act.update_attributes!(params[:act])
	    @act.completion = @act.completedness
	    @act.save!

	    unless params[:pictures].nil? 
	      params[:pictures].each do |pic|
	          #puts pic
	          #puts pic[1]["id"]
	          addedPic = Picture.find(pic[1]["id"])
	          addedPic.pictureable_id = @act.id
	          addedPic.save!
	      end
	    end
	    respond_to do |format|
			format.json {render :json => { :tags => @act.tags.collect { |t| t.id}, :id => @act.id, :name => @act.name, :completedness => @act.completedness }}
			format.html 
		end
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
			search_match_arr.push("(regexp_replace(venues.name, '[^0-9a-zA-Z ]', '') ILIKE '%#{word}%' 
								    OR regexp_replace(events.description, '[^0-9a-zA-Z ]', '') ILIKE '%#{word}%' 
								    OR regexp_replace(events.title, '[^0-9a-zA-Z ]', '') ILIKE '%#{word}%' 
								    OR regexp_replace(acts.name, '[^0-9a-zA-Z ]', '') ILIKE '%#{word}%')")

			#("(venues.name ILIKE '%#{word}%' OR events.description ILIKE '%#{word}%' OR events.title ILIKE '%#{word}%' OR acts.name ILIKE '%#{word}%')")


									
			end

			search_match = search_match_arr * " AND "

			query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id, events.id AS event_id FROM occurrences
					INNER JOIN events ON occurrences.event_id = events.id
		         	INNER JOIN venues ON events.venue_id = venues.id
                    LEFT OUTER JOIN acts_events ON events.id = acts_events.event_id
                    LEFT OUTER JOIN acts ON acts.id = acts_events.act_id
		         		WHERE #{search_match} AND occurrences.deleted IS NOT true AND occurrences.start > NOW()
		         		ORDER BY events.id, occurrences.start LIMIT 10"

		    @occurrence_ids = ActiveRecord::Base.connection.select_all(query).collect { |e| e["occurrence_id"].to_i }
		    @occurrences = Occurrence.find(@occurrence_ids)

		    respond_to do |format|
		    	format.json { render json: @occurrences.to_json(:include => {:event => {:only => [:title, :id], :include => [:venue => {:only => [:name]}] }})}
		    end
	    end


	end
end