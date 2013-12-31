class Admin::DashboardController < ApplicationController
  before_filter :authenticate_user!
  layout 'dashboard'

  def index
    @selected_sidebar_li = 'ads'
    @advertisements = Advertisement.order('created_at ' 'desc').paginate(:page => params[:page] || 1, :per_page => 10)
    @user = current_user rescue nil
  end
end
