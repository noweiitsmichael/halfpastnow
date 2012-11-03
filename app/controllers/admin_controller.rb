
class AdminController < ApplicationController
	layout "admin"
	before_filter :authenticate_user!
	
	def controlPanel
	end

	def index
	end

	def test
	end

	def admin_table
		@array = []
		@array << ['Jack', 5, 3, 2]
		@array << ['Jill', 6, 2, 1]

		render json: @array
	end
	

end
