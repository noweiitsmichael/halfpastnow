class Admin::AdvertisementsController < ApplicationController
  before_filter :authenticate_user!
  layout 'dashboard'

  def new
    @selected_sidebar_li = 'ads'
    @advertisement = Advertisement.new
  end

  def create
    #raise params.inspect
    @advertisement = current_user.advertisements.build(params[:advertisement])
    #raise @advertisement.inspect
    respond_to do |format|
      if @advertisement.save!
        format.html { redirect_to admin_dashboard_index_path, notice: 'Advertisement was successfully created.' }
        format.json { render json: @advertisement, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @advertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @selected_sidebar_li = 'ads'
    @advertisement = Advertisement.find(params[:id])
  end

  def update_ads_details
    advertisement = Advertisement.find(params[:pk])
    params[:name] = params[:name].split("-").last
    advertisement.update_attributes({params[:name] => params[:value]})
    render status: 200, nothing: true
  end

  def update_ads_pic
    advertisement = Advertisement.find(params[:id])
    advertisement.update_attributes({image: params[:image]})
    render status: 200, nothing: true
  end
end
