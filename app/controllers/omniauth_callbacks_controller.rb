class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	# def all
	# 	raise request.env["omniauth.auth"].to_yaml
	# end

	# alias_method :facebook, :all

	def facebook
	    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
	    puts "First FB"
	    if @user.persisted?
	       puts "Second FB"
	      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
	      sign_in_and_redirect @user, :event => :authentication
	    else
	    	 puts "Third FB"
	      session["devise.facebook_data"] = request.env["omniauth.auth"]
	      redirect_to new_user_registration_url
	    end
	end

end
