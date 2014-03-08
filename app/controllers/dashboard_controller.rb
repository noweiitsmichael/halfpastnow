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
    @bookmark_list = BookmarkList.find(params[:id])
    @bookmarks = @bookmark_list.bookmarks.order('created_at ' 'desc')
    render layout: false if request.xhr?
  end

  def update_bookmark_list
    bookmark_list = BookmarkList.find(params[:pk])
    bookmark_list.update_attributes({params[:name] => params[:value]})
    render status: 200, nothing: true
  end

  def update_bookmark_list_picture
    bookmark_list = BookmarkList.find(params[:id])
    bookmark_list.update_attributes({picture: params[:picture]})
    render status: 200, nothing: true
  end

  def preferences
    @selected_sidebar_li = 'preferences'
    @user = current_user rescue nil
  end
end
