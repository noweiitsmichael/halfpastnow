class IStillHateTimestamps < ActiveRecord::Migration
  def change
  	remove_timestamps :bookmark_lists_users
  end
end
