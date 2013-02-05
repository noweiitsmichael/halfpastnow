class ApplicationController < ActionController::Base
  
  layout :layout_by_resource
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
     redirect_to root_path, :alert => "Access Denied!"
   end
  
  # # Mobile stuff 
  before_filter :prepare_for_mobile , :common_content
  
  # private
  
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      # request.user_agent =~ /Mobile|webOS/
       (request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /Android/) &&  (request.user_agent !~ /iPad/)
    end
  end
  helper_method :mobile_device?
  
  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
    @some_instance_variable = mobile_device?
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
   
  protected

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
  

end
