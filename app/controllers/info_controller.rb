class InfoController < ApplicationController
  layout "devise"
  
  def about
  end

  def contact
  end

  def privacy
  end

  def terms
  end

   def unsubscribe
    
    e=Email.find_by_email(params[:email])
    unless e.nil?
      e.destroy 
      user =  User.find_by_email(params[:email])
      unless user.nil?
        channel = Channel.find(user.ref.to_i)
        channel.included_tags=""
        channel.save   
      end
     
     
    end
    
    
  end

end
