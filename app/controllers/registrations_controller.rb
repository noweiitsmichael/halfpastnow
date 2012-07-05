class RegistrationsController < Devise::RegistrationsController

  # New update function to allow for resizing
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
	    if resource.update_without_password(params[resource_name])
	      if is_navigational_format?
	        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
	          flash_key = :update_needs_confirmation
	        end
	        set_flash_message :notice, flash_key || :updated
	      end

	      sign_in resource_name, resource, :bypass => true
	      # puts "First if stmt:"
	      # puts params[:user][:profilepic].present?

	      if params[:user][:profilepic].present?
	    		render :crop
	   	  else
	        respond_with resource, :location => after_update_path_for(resource)
	      end
	    else
	      clean_up_passwords resource
	      	# puts "second if stmt:"
	      	# puts params[:user][:profilepic].present?
	        if params[:user][:profilepic].present?
	    		render :crop
	   		else
				respond_with resource, :location => after_update_path_for(resource)
			end
	    end
  end
end