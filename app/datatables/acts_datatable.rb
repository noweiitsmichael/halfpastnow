require 'pp'
require 'will_paginate/array'
class ActsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view

    # puts "****printing Venuesraw *****"

    #pp params
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Act.count,
      iTotalDisplayRecords: entries,
      aaData: data
    }
  end

private

  def data
    acts.map do |venue|
      [
        link_to(act["name"], "/userSubmission/actEdit/" + act["act_id"]),
        h(act["completion"]),
        h(act["num_events"])
      ]
    end
  end

  def acts
    @acts ||= fetch_acts
  end

  def fetch_acts
    acts_query = Act.joins("LEFT OUTER JOIN acts_events ON acts.id = acts_events.act_id GROUP BY acts.id").select("acts.id, acts.name, acts.completion, COUNT(acts_events.act_id) as num_events")

    if params[:sSearch].present?
      acts_query += " WHERE v2.name ilike '%" + params[:sSearch].sub("'", "''") + "%'"
    end

    acts_query += " ORDER BY " + sort_column + " " + sort_direction
    acts_query += " LIMIT " + params[:iDisplayLength] + " OFFSET " + params[:iDisplayStart]

    venues = ActiveRecord::Base.connection.select_all(acts_query)

    acts
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name address views events_count raw_events_count assignee]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def entries
    acts_query = Act.joins("LEFT OUTER JOIN acts_events ON acts.id = acts_events.act_id GROUP BY acts.id").select("acts.id, acts.name, acts.completion, COUNT(acts_events.act_id) as num_events")

    if params[:sSearch].present?
      acts_query += " WHERE v2.name ilike '%" + params[:sSearch].sub("'", "''") + "%'"
    end

    num_results = ActiveRecord::Base.connection.select_all("SELECT COUNT(*) FROM ( " + acts_query + " ) AS numResults")
    resultCount = num_results[0]["count"].to_i
    resultCount
  end

end
