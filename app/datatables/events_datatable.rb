require 'pp'
require 'will_paginate/array'
class EventsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view

    # puts "****printing Venuesraw *****"

    #pp params
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Event.count,
      iTotalDisplayRecords: events.total_entries,
      aaData: data
    }
  end

private

  def data
    venues.map do |venue|
      [
        link_to(venue["name"], "/venues/edit/" + venue["venue_id"]),
        h(venue["address"]),
        h(venue["views"]),
        h(venue["events_count"]),
        h(venue["raw_events_count"])
      ]
    end
  end

  def venues
    @venues ||= fetch_venues
  end

  def fetch_venues

    venues_query = "
      SELECT v2.venue_id, v2.name, v2.address, v2.views, v2.events_count, COALESCE(v1.raw_events_count, 0) AS raw_events_count FROM
        ( SELECT venue_id,venues.name,COUNT(*) AS raw_events_count
          FROM venues,raw_venues,raw_events 
          WHERE venues.id = raw_venues.venue_id AND raw_venues.id = raw_events.raw_venue_id AND raw_events.submitted IS NULL AND raw_events.deleted IS NULL
          GROUP BY venue_id,venues.name ) v1
      FULL OUTER JOIN
        ( SELECT venues.id AS venue_id, venues.name, venues.address, venues.views, COUNT(events.id) AS events_count
          FROM venues
          LEFT OUTER JOIN events
          ON venues.id = events.venue_id
          GROUP BY venues.id,venues.name ) v2
      ON v1.venue_id = v2.venue_id"

    #[√] If sort_column is name, address, or clicks, append ORDER BY to venues
    # if ((sort_column == "name") || (sort_column == "address") || (sort_column == "views"))
    venues_query += " ORDER BY " + sort_column + " " + sort_direction
    venues = ActiveRecord::Base.connection.select_all(venues_query)
    #[ ] TODO: If sort_column is completion, append some complicated shit
    #elsif (sort_column == "completedness")
    # end

    #[√] Combine venues and venues_with_raw
    # venues_with_events = ActiveRecord::Base.connection.select_all(venues_with_existing_events_query)

    # venues.each do |venue|
    #   intersect_venue = venues_with_raw.find{|id| id["venue_id"] == venue["id"]}
    #   intersect_venue.nil? ? venue.merge!({ "raw_events_count" => "0"}) : venue.merge!({ "raw_events_count" => intersect_venue["count"]})
    # end

    #[√] if sort_column is event/rawevent count, do sort via ruby
    # if (sort_column == "events_count")
    #   sort_direction == "asc" ? venues = venues.sort_by {|u| u["events_count"].to_i} : venues = venues.sort_by {|u| u["events_count"].to_i}.reverse
    # elsif (sort_column == "raw_events_count")
    #   sort_direction == "asc" ? venues = venues.sort_by {|u| u["raw_events_count"].to_i} : venues = venues.sort_by {|u| u["raw_events_count"].to_i}.reverse
    # end
    
    if params[:sSearch].present?
      puts "Search term detected: " + params[:sSearch].downcase
      venues = venues.select {|s| s["name"].downcase.include? params[:sSearch].downcase}
    end

    venues = venues.paginate(:page => page, :per_page => per_page)

    venues
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name address views events_count raw_events_count]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
