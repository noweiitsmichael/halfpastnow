require 'pp'
class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :xml, :json
  def update
  	self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
	if params[resource_name][:password].blank? ? resource.update_without_password(params[resource_name]) 
											   : resource.update_with_password(params[resource_name])
		puts "update success"			   
		sign_in resource_name, resource, :bypass => true
		pp resource	
		# respond_with resource
		render json: resource
	else
		puts "update fail"
		clean_up_passwords resource
		pp resource
		render json: resource
	end
  end
end