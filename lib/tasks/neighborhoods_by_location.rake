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
          neighborhood = Neighborhood.find_by_name_and_n_id(nh_name,result['id'])
          unless neighborhood
            Neighborhood.create(
                                name: nh_name,
                                n_id: result['id'],
                                city: result['city'],
                                state:  result['state'],
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
end