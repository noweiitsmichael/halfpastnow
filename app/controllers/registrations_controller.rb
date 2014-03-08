require 'pp'
class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :xml, :json
  #layout "new_design"
  def update
  	# if ( params[:item][:done].to_s == '1') 
  	# 	puts 'Its checked'
  	# else 
  	# 	puts 'its not checked'
  	# end
  	self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
  	
	if params[resource_name][:password].blank? ? resource.update_without_password(params[resource_name]) 
											   : resource.update_with_password(params[resource_name])			   
		sign_in resource_name, resource, :bypass => true
		# respond_with resource
		render json: resource
	else
		clean_up_passwords resource
		render json: resource
	end
  end

  def update_password
    @errors = false
    @errors_msg = ''
    if params[resource_name][:password].blank?
      @errors = true
      @errors_msg += "Password can't be Blank" + "<br>"
    end

    if params[resource_name][:password].to_s != params[resource_name][:password_confirmation]
      @errors = true
      @errors_msg += "Password and Password confirmation must be same" + "<br>"
    end

    if params[resource_name][:current_password].blank?
      @errors = true
      @errors_msg += "Current Password can't be Blank"
    end

    unless @errors
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      resource.update_with_password(params[resource_name])
      sign_in resource_name, resource, :bypass => true
    end
  end
end