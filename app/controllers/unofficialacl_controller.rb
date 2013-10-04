class UnofficialaclController < ApplicationController

  def index

    join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                     INNER JOIN venues ON events.venue_id = venues.id
                     LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                     LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id"

    where_clause = "venues.id = events.venue_id AND venues.latitude >= 30.14525713491939 AND venues.latitude <= 30.39077536652272 AND venues.longitude >= -97.85129799023434 AND venues.longitude <= -97.6343180097656"

    if Time.now.hour < 17
      start_date_where = "'#{(Time.now - 2.hours)}'"
    else
      start_date_where = "'#{(Time.now - 3.hours)}'"
    end

    query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id,  events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences #{join_clause} WHERE #{where_clause}
              AND tags.id IN (232) AND occurrences.start >= #{start_date_where} AND occurrences.deleted IS NOT TRUE
              LIMIT 500"

    #raise query.to_yaml

    occurrence_ids = []
    default_occurrence_ids = []
    ids = ActiveRecord::Base.connection.select_all(query)
    occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq

    occurrences = Occurrence.where("id in (?)",occurrence_ids).order("start")
    @occurrences = occurrences.paginate(:page => params[:page] || 1, :per_page => 19)

    default_occurrence_ids = occurrence_ids[0..13]
    occurrence_ids = occurrence_ids - default_occurrence_ids
    #raise @occurrences.count.to_yaml

    #venues for default page
    @default_venues=Venue.where("id in (?)",[39473,39334,39349,47138,39329])
    @default_occurrences = Occurrence.where("id in (?)",default_occurrence_ids).order("start")

    render :layout => "unofficialacl"
  end

  def search

    search_match = occurrence_match = tag_include_match = tag_and_match = "TRUE"

    join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                     INNER JOIN venues ON events.venue_id = venues.id
                     LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                     LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id"

    unless params[:search].to_s.empty?# and params[:category_search].to_s.empty?
      search_word = params[:search].to_s
      #raise search_word.to_yaml
      search = search_word.gsub(/[^0-9a-z ]/i, '').upcase
      searches = search.split(' ')

      search_match_arr = []
      searches.each do |word|
        search_match_arr.push("(upper(venues.name) LIKE '%#{word}%' OR upper(events.description) LIKE '%#{word}%' OR upper(events.title) LIKE '%#{word}%')")
      end

      search_match = search_match_arr * " AND "
    end

    unless params[:time_search].to_s.empty? or params[:time_search] == "everything"
       if params[:time_search] == "first"
         event_start_date = Date.parse('2013-10-04')
         event_end_date = Date.parse('2013-10-06').advance(:days => 1)
       elsif params[:time_search] == "unofficial"
         event_start_date = Date.parse('2013-10-07')
         event_end_date = Date.parse('2013-10-10').advance(:days => 1)
       elsif params[:time_search] == "second"
         event_start_date = Date.parse('2013-10-11')
         event_end_date = Date.parse('2013-10-13').advance(:days => 1)
       elsif params[:time_search] == "today"
         event_start_date = Date.today()
         event_end_date = Date.today().advance(:days => 1)
       elsif params[:time_search] == "tomorrow"
         event_start_date = Date.today().advance(:days => 1)
         event_end_date = Date.today().advance(:days => 2)
       end

       start_date_check = "occurrences.start >= '#{event_start_date}'"
       end_date_check = "occurrences.start <= '#{event_end_date}'"
       occurrence_match = "#{start_date_check} AND #{end_date_check}"
    end


    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end

    if(params[:and_tags] && params[:and_tags].is_a?(String))
      params[:and_tags] = params[:and_tags].split(",")
    end

    if params[:tags]
      params[:and_tags] = "247" if params[:tags] == "Official Late Night Shows"
      params[:and_tags] = "230" if params[:tags] == "Official ACL"
      params[:and_tags] = "256" if params[:tags] == "Free drinks"
       params[:and_tags] = "253" if params[:tags] == "party"
       params[:and_tags] = "254" if params[:tags] == "no cover"
       params[:and_tags] = "255" if params[:tags] == "RSVP"
       params[:and_tags] = params[:and_tags].split(",")
    end

    unless(params[:included_tags].to_s.empty?)
      tags_mush = params[:included_tags] * ','
      tag_include_match = "tags.id IN (#{tags_mush})"
    end

    # tags
    unless(params[:and_tags].to_s.empty?)
      tags_mush = params[:and_tags] * ','

      tag_and_match = "events.id IN (
                      SELECT event_id
                        FROM events, tags, events_tags
                        WHERE events_tags.event_id = events.id AND events_tags.tag_id = tags.id AND tags.id IN (#{tags_mush})
                        GROUP BY event_id
                        HAVING COUNT(tag_id) >= #{ params[:and_tags].count }
                    )"
    end

    where_clause = "#{search_match} AND #{occurrence_match} AND #{tag_include_match} AND #{tag_and_match}"

    if Time.now.hour < 17
      start_date_where = "'#{(Time.now - 2.hours)}'"
    else
      start_date_where = "'#{(Time.now - 3.hours)}'"
    end

    query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id,  events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences
                #{join_clause}
              WHERE #{where_clause}
              AND tags.id IN (232,230,247) AND occurrences.start >= #{start_date_where} AND occurrences.deleted IS NOT TRUE
              LIMIT 500"

    ids = ActiveRecord::Base.connection.select_all(query)
    occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq
    @occurrences = Occurrence.where("id in (?)",occurrence_ids).order("start")
    @occurrences = @occurrences.paginate(:page => params[:page] || 1, :per_page => 19)
    #render 'unofficialacl/results' unless request.xhr?
    #raise query.to_yaml
    render :layout => "unofficialacl"
  end

  def details
    #raise  params[:event_id].to_yaml
    @occurrence = Occurrence.find_by_id(params[:id])
    #raise @occurrence.to_yaml
    unless @occurrence.nil?
      @event = @occurrence.event
      @venue = @occurrence.event.venue
      @acts = @event.acts


      #venue events
      @occurrences  = []
      @recurrences = []
      occs = @venue.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
      occs.each do |occ|
        # check if occurrence is instance of a recurrence
        if occ.recurrence.nil?
          @occurrences << occ
        else
          if @recurrences.index(occ.recurrence).nil?
            @recurrences << occ.recurrence
          end
        end
      end

      #artist events

      @a_occurrences  = []
      @a_recurrences = []
      act = @event.acts[0]
      unless act.nil?
        occs = act.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
        occs.each do |occ|
          # check if occurrence is instance of a recurrence
          if occ.recurrence_id.nil?
            @a_occurrences << occ
          else
            if @a_recurrences.index(occ.recurrence).nil?
              @a_recurrences << occ.recurrence
            end
          end
        end
        @a_recurrences.reject! { |c| c.nil? }
        @a_occurrences.reject! { |c| c.nil? }
      end

      render :layout => "unofficialacl"
    else
      redirect_to :controller => :unofficialacl,:action => :index
    end

  end

  def show_venue
    @venue = Venue.find_by_id(params[:id])
    @occurrences  = []
    @recurrences = []
    occs = @venue.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
    occs.each do |occ|
      # check if occurrence is instance of a recurrence
      if occ.recurrence.nil?
        @occurrences << occ
      else
        if @recurrences.index(occ.recurrence).nil?
          @recurrences << occ.recurrence
        end
      end
    end
    render :layout => "unofficialacl"
  end

  def show_artist
    @a_occurrences  = []
    @a_recurrences = []
    @act = Act.find_by_id params[:id]
    act = @act
    unless act.nil?
      occs = act.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
      occs.each do |occ|
        # check if occurrence is instance of a recurrence
        if occ.recurrence_id.nil?
          @a_occurrences << occ
        else
          if @a_recurrences.index(occ.recurrence).nil?
            @a_recurrences << occ.recurrence
          end
        end
      end
      @a_recurrences.reject! { |c| c.nil? }
      @a_occurrences.reject! { |c| c.nil? }
    else
      redirect_to :controller => :unofficialacl,:action => :index
    end
  end

  def find_all
    #occurrences=Occurrence.where("start >= ?", Time.now)
    #occurrences.each do |occurrence|
    #  event = occurrence.event
    #  venue = event.venue unless event.nil?
    #  tags = event.tags unless event.nil?
    #end
  end



end
