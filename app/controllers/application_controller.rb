class ApplicationController < ActionController::Base
  
  layout :layout_by_resource
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
     redirect_to root_path, :alert => "Access Denied!"
   end
  
  # # Mobile stuff 
  before_filter :prepare_for_mobile , :common_content

  #Preload models for caching
  before_filter  :preload_models
  
  # private
  
  def mobile_device?
    if session[:mobile_param]
       session[:mobile_param] == "1"
    else
      
      # request.user_agent =~ /Mobile|webOS/
       (request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /Android/) &&  (request.user_agent !~ /iPad/) &&  (request.user_agent !~ /iPhone/) &&  (request.user_agent !~ /iPod/)
      
    end
  end
  helper_method :mobile_device?
  
  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
    @some_instance_variable = mobile_device?
    @switch="test"
    if !@some_instance_variable.nil?
      @mobileMode = true
      
    else
      
      
      @mobileMode = false
    end

  end
 
  def common_content
    
  end 
   def logged_in?
     true
   end

   def admin_logged_in?
     true
   end  
   def after_sign_in_path_for(resource)
     unless current_user
       cookies[:url]
     end
   end
  protected

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def preload_models()
    BookmarkList
    Occurrence
    Bookmark
    Event
    Venue
    User
    Act
  end
  

end
