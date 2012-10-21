class AdminController < ApplicationController
	layout "admin"
	before_filter :authenticate_user!
	
	def controlPanel
	end

	def index
	end

	def test
	end
	

end
