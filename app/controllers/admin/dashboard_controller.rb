class Admin::DashboardController < ApplicationController
  before_filter :authenticate_user!
  layout 'dashboard'

  def index
    @selected_sidebar_li = 'ads'
    @advertisements = current_user.advertisements.all
    @user = current_user rescue nil
  end
end
