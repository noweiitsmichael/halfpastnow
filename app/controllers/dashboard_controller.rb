class DashboardController < ApplicationController
  layout 'dashboard'

  def index
    @selected_sidebar_li = 'dashboard'
  end

  def profile
    @selected_sidebar_li = 'profile'
    @user = current_user rescue nil
  end

  def settings
    @selected_sidebar_li = 'settings'
    @user = current_user rescue nil
  end

  def saved_searches
    @selected_sidebar_li = 'saved_searches'
    @user = current_user rescue nil
  end

  def preferences
    @selected_sidebar_li = 'preferences'
    @user = current_user rescue nil
  end
end
