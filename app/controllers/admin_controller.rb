
class AdminController < ApplicationController
	layout "admin"
	
	
	def controlPanel
	end

	def index
		authorize! :index, @user, :message => 'Not authorized as an administrator.'
		puts "index"
	end

	def test
	end

	def admin_table

	end
	

end
