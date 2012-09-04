class AddFbPictureToRawVenuesAndRawEvents < ActiveRecord::Migration
  def change
  	add_column :raw_events, :fb_picture, :string
    add_column :raw_venues, :fb_picture, :string
  end
end
