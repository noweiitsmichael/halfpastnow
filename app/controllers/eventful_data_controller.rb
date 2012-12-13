class EventfulDataController < ApplicationController

  def create

    @eventfuldata = EventfulData.new(params[:eventfuldata])

    respond_to do |format|
      if @eventfuldata.save
        format.html { render :nothing => true }
        format.json { render json: @picture }
      else
        format.html { render :nothing => true }
        format.json { render json: @picture }
      end
    end
  end

  def new
    @eventfuldata = EventfulData.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @picture }
    end
  end


end
