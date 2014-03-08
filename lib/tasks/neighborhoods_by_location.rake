include Yelp::V1::Review::Request
namespace :neighborhoods do
  client = Yelp::Client.new
  desc 'Update neighborhoods data by location'
  task :location => :environment do
    location = ENV['LOCATION']
    puts "location: #{location}"
    unless location.nil?
      request = Location.new(
        :address => location)
      response = client.search(request)
      results = response['businesses']
      puts "results started"
      results.each do |result|
        begin
          nh_name = result['neighborhoods'].first['name']
          neighborhood = Neighborhood.find_by_name_and_n_id(nh_name, result['id'])
          unless neighborhood
            Neighborhood.create(
              name: nh_name,
              n_id: result['id'],
              city: result['city'],
              state: result['state'],
              state_code: result['state_code'],
              country: result['country'],
              country_code: result['country_code'],
              url: result['url']
            )
            puts "neighborhood: #{nh_name} done!"
          end
        rescue Exception => e
          puts "error: #{e}"
          puts "result-neighborhoods: #{result['neighborhoods']}"
          Rails.logger.info "error: #{e}"
          Rails.logger.info "result-neighborhoods: #{result['neighborhoods']}"
          next
        end
      end
      puts "results ended"
    end
  end

  desc "Getting venue locations"
  task :populate => :environment do
    vnf = VenueNeighbourhoodFetch.where(start_date: "2014-01-28").first_or_initialize(count: 0)
    venues = Venue.where("id > ?", vnf.count).order("id asc").limit(100)
    venues.each do |venue|
      puts venue.id
      api_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{venue.latitude},#{venue.longitude}&rank=distance&radius=500&sensor=false&key=AIzaSyCz-NFeLCS7_8hurfNFQvKOiqyfwvxtbJU"
      #puts api_url
      response = HTTParty.get(api_url)
      _response_body = JSON.parse(response.body)
      results = _response_body["results"]
      result = results.first
      #puts result
      if result
        _name = result["name"]
        _n_id = result["id"]
        puts _name
        neighborhood = Neighborhood.where(name: _name, n_id: _n_id).first
        unless neighborhood
          neighborhood = Neighborhood.new(
            name: result["name"],
            n_id: result["id"],
            reference: result["reference"]
          )
        end
        neighborhood.venues << venue
        neighborhood.save
        vnf.count = venue.id
        vnf.save
      end
    end
  end
end