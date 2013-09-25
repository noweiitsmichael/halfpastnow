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
              AND tags.id IN (25) AND occurrences.start >= #{start_date_where} AND occurrences.deleted IS NOT TRUE
              ORDER BY events.id, occurrences.start LIMIT 1000"

    #raise query.to_yaml

    ids = ActiveRecord::Base.connection.select_all(query)
    occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq
    @occurrences = Occurrence.where("id in (?)",occurrence_ids)
    #raise @occurrences.to_yaml

    render layout: "unofficialacl"
  end

  def search
    search_match = tag_include_match = tag_and_match = "TRUE"

    join_clause = "INNER JOIN events ON occurrences.event_id = events.id
                     INNER JOIN venues ON events.venue_id = venues.id
                     LEFT OUTER JOIN events_tags ON events.id = events_tags.event_id
                     LEFT OUTER JOIN tags ON tags.id = events_tags.tag_id"

    unless(params[:search].to_s.empty?)
      search = params[:search].gsub(/[^0-9a-z ]/i, '').upcase
      searches = search.split(' ')

      search_match_arr = []
      searches.each do |word|
        search_match_arr.push("(upper(venues.name) LIKE '%#{word}%' OR upper(events.description) LIKE '%#{word}%' OR upper(events.title) LIKE '%#{word}%')")
      end

      search_match = search_match_arr * " AND "
    end

    if(params[:included_tags] && params[:included_tags].is_a?(String))
      params[:included_tags] = params[:included_tags].split(",")
    end

    if(params[:and_tags] && params[:and_tags].is_a?(String))
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

    where_clause = "#{search_match} AND #{tag_include_match} AND #{tag_and_match}"

    if Time.now.hour < 17
      start_date_where = "'#{(Time.now - 2.hours)}'"
    else
      start_date_where = "'#{(Time.now - 3.hours)}'"
    end

    query = "SELECT DISTINCT ON (events.id) occurrences.id AS occurrence_id,  events.id AS event_id, venues.id AS venue_id, occurrences.start AS occurrence_start
              FROM occurrences
                #{join_clause}
              WHERE #{where_clause}
              AND tags.id IN (25) AND occurrences.start >= #{start_date_where} AND occurrences.deleted IS NOT TRUE
              ORDER BY events.id, occurrences.start LIMIT 1000"
    ids = ActiveRecord::Base.connection.select_all(query)
    occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq
    @occurrences = Occurrence.where("id in (?)",occurrence_ids)
    #render layout: "unofficialacl"
  end

  def show_event
    @occurrence = Occurrence.find params[:event_id]
    @event = @occurrence.event
    @venue = @occurrence.event.venue
    @acts = @event.acts
    render layout: "unofficialacl"
  end

  def show_venue
    @occurrence = Occurrence.find params[:event_id]
    @venue = @occurrence.event.venue
    render layout: "unofficialacl"
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
