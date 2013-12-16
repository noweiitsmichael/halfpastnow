class DashboardController < ApplicationController
  before_filter :authenticate_user!
  layout 'dashboard'

  def profile
    @selected_sidebar_li = 'profile'
    @user = current_user rescue nil
  end

  def update_profile
    current_user.update_attributes({params[:name] => params[:value]})
    render status: 200, nothing: true
  end

  def update_profile_pic
    current_user.update_attributes({:profilepic => params[:profilepic]})
    render status: 200, nothing: true
  end

  def settings
    @selected_sidebar_li = 'settings'
    @user = current_user rescue nil
  end

  def my_list
    @selected_sidebar_li = 'my_list'
    @user = current_user rescue nil
    @bookmark_lists = @user.bookmark_lists.order('name')
  end

  def bookmarks
    bookmark_list = BookmarkList.find(params[:id])
    @bookmarks = bookmark_list.bookmarks
    render layout: false if request.xhr?
  end

  def preferences
    @selected_sidebar_li = 'preferences'
    @user = current_user rescue nil
  end
end
