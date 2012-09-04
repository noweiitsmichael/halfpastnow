class AddFbPictureToVenuesUsersEventsAndActs < ActiveRecord::Migration
  def change
  	add_column :venues, :fb_picture, :string
    add_column :acts, :fb_picture, :string
    add_column :events, :fb_picture, :string
    add_column :users, :fb_picture, :string
  end
end
