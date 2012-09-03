class TagsController < ApplicationController
  def index
    puts params
    if request.post? 
      
    end

    @parentTags = Tag.all(:conditions => {:parent_tag_id => nil})
    
    render :layout => 'venues'

  end

  def create
  	parent_id = (params[:parent_id]) ? params[:parent_id].to_i : nil
  	tag = Tag.new(:name => params[:name], :parent_tag_id => parent_id)
  	tag.save

  	redirect_to :action => "index"
  end

  def rename(tag, new_name)
    tag.name = new_name
  end

end
