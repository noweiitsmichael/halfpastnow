class ChangeFbPictureWebsiteToTextInVenueAndEvents < ActiveRecord::Migration
  def up
  	add_column :events, :url, :text
  	change_column :venues, :url, :text
  	change_column :venues, :fb_picture, :text
  	change_column :events, :url, :text
  	change_column :events, :fb_picture, :text
  	change_column :raw_venues, :url, :text
  	change_column :raw_venues, :fb_picture, :text
  	change_column :raw_events, :url, :text
  	change_column :raw_events, :fb_picture, :text
  end

  def down
  	remove_column :events, :url, :text
  	change_column :venues, :url, :string
  	change_column :venues, :fb_picture, :string
  	change_column :events, :url, :string
  	change_column :events, :fb_picture, :string
  	change_column :raw_venues, :url, :string
  	change_column :raw_venues, :fb_picture, :string
  	change_column :raw_events, :url, :string
  	change_column :raw_events, :fb_picture, :string
  end
end
