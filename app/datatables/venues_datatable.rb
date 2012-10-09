require 'pp'
class VenuesDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view

    puts "****printing Venuesraw *****"

    puts "****printing @view *****"
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Venue.count,
      iTotalDisplayRecords: venues.total_entries,
      aaData: data
    }
  end

private

  def data
    venues.map do |venue|
    puts "Original Venue...."
    puts "New Hash....."

      [
        link_to(venue.name, venue),
        h(venue.address),
        h(venue.views),
        h(Event.where(:id => venue.id).count)
      ]
    end
  end

  def venues
    @venues ||= fetch_venues
  end

  def fetch_venues
    venues = Venue.order("#{sort_column} #{sort_direction}")
    venues = venues.page(page).per_page(per_page)
    if params[:sSearch].present?
      venues = venues.where("name ilike :search or address ilike :search", search: "%#{params[:sSearch]}%")
    end
    venues
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name address views events_count]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end