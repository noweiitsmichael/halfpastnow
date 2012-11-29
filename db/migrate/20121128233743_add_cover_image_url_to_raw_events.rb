class AddCoverImageUrlToRawEvents < ActiveRecord::Migration
  def change
  	add_column :raw_events, :cover_image_url, :string
  end
end
