module AdminHelper

	def admin_table_data
		@array = []
		@array << ['User', 'Events', 'Venues', 'Acts']
		User.all.each do |u|
			@array << [u.firstname + " " + u.lastname, Event.where(:user_id => u.id).count, Venue.where(:updated_by => u.id.to_s).count, Act.where(:updated_by => u.id.to_s).count]
		end

		return @array
	end
	
end
