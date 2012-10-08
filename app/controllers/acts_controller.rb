class ActsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index]

  layout "venues"

  def show
    @act = Act.find(params[:id])
    @occurrences  = []
    @recurrences = []
    @pictures = []
    @occs = @act.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
    @occs.each do |occ|
      # check if occurrence is instance of a recurrence
      if occ.recurrence_id.nil?
        @occurrences << occ
      else
        if @recurrences.index(occ.recurrence).nil?
          @recurrences << occ.recurrence
        end
      end
    end

    @act.pictures.each do |pic|
      @pictures << pic
    end

    respond_to do |format|
      format.html { render :layout => "mode" }
      format.json { render json: { :occurrences => @occurrences.to_json(:include => :event), :recurrences => @recurrences.to_json(:include => :event), 
                                   :act => @act.to_json, :pictures => @pictures.to_json } } 
    end
  end

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @acts = Act.includes(:events, :tags, :embeds).all.sort_by{ |act| act.name }

    render :layout => "admin"
  end
end
