class PicturesController < ApplicationController
   def index
    @pictures = Picture.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pictures }
    end
  end

  def create
    puts "Pic Create"
    # puts params
    params[:picture][:remote_image_url] = params[:picture][:remote_image_url].strip
    @picture = Picture.new(params[:picture])

    respond_to do |format|
      if @picture.save
        format.html { render :nothing => true }
        format.json { render json: @picture }
      else
        format.html { render :nothing => true }
        format.json { render json: @picture }
      end
    end
  end

  def new
    @picture = Picture.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @picture }
    end
  end

  def delete
    puts "pic delete"
    @picture = Picture.find(params[:id])
    @picture.destroy

    respond_to do |format|
      format.html 
      format.json { head :ok }
    end
  end

  def update
    # pp params
  end

  def createFromData
    # puts "Pic CreatefromData"
    # pp params
    pictureParams = {} 
    pictureParams[:pictureable_type] = params[:pictureable_type]
    pictureParams[:pictureable_id] = params[:pictureable_id]
    pictureParams[:image] = params[:venue][:image]

    # pp pictureParams

    @picture = Picture.new(pictureParams)

    respond_to do |format|
      if @picture.save
        format.html { render :nothing => true }
        format.json { render json: @picture }
      else
        format.html { render :nothing => true }
        format.json { render json: @picture }
      end
    end
  end

  def createForAct
    # puts "Pic CreatefromData"
    # pp params
    pictureParams = {} 
    pictureParams[:pictureable_type] = params[:pictureable_type]
    pictureParams[:pictureable_id] = params[:pictureable_id]
    pictureParams[:image] = params[:act][:image]


    @picture = Picture.new(pictureParams)

    respond_to do |format|
      if @picture.save
        format.html { render :nothing => true }
        format.json { render json: @picture }
      else
        format.html { render :nothing => true }
        format.json { render json: @picture }
      end
    end
  end

  def createForEvent
    puts "Pic CreateForEvent"
    # pp params
    pictureParams = {} 
    pictureParams[:pictureable_type] = params[:pictureable_type]
    if params[:pictureable_id] == 0
      pictureParams[:pictureable_id] = nil
    else
      pictureParams[:pictureable_id] = params[:pictureable_id]
    end
    pictureParams[:image] = params[:event][:image]

    # pp pictureParams
    @picture = Picture.new(pictureParams)

    respond_to do |format|
      if @picture.save
        format.html { render :nothing => true }
        format.json { render json: @picture }
      else
        format.html { render :nothing => true }
        format.json { render json: @picture }
      end
    end
  end

  def coverImageAdd
     puts "cover Picture Crop function"
     # pp params
    @picture = Picture.find(params[:picture][:id])

    # Saves to either raw event or event, we'll copy the cover_image over to raw event later
    # unless @event.nil?
      if params[:picType] == "Event"
        @event = Event.find(params[:id])
        pp params
        event_hash = {"cover_image" => params[:cover_image], "cover_image_url" => Picture.find(params[:cover_image]).image_url(:cover)}
        @event.update_attributes!(event_hash)
      elsif params[:picType] == "rawEvent"
        @event = RawEvent.find(params[:id])
        event_hash = {"cover_image" => params[:cover_image], "cover_image_url" => Picture.find(params[:cover_image]).image_url(:cover)}
        @event.update_attributes!(event_hash)
      end
    # end
    # pp @event

    respond_to do |format|
      if @picture.update_attributes!(params[:picture])
        format.html { render :nothing => true }
        format.json { render json: { event: @event, pictures: @picture} }
      else
        format.html { render :nothing => true }
        format.json { render json: @event }
      end
    end
  end

  def cropMode
    # puts "cropMode Params:"
    # puts params
    # puts params[:picture_type]
    # puts params[:picture_id]
    @picURL = params[:picture_url]
    @picture = Picture.find(params[:picture_id])
    # pp @picture
    if params[:picture_type] == "Event"
      if params[:event_id] == '0'
        @eventType = "Newevent"
      else
        @event = Event.find(params[:event_id])
        @eventType = "Event"
      end
    else
      if params[:event_id] != '0'
        @event = RawEvent.find(params[:event_id])
      end
      @eventType = "rawEvent"
    end

    render :layout => false
  end

end
