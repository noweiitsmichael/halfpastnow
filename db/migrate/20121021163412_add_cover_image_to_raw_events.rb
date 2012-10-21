class AddCoverImageToRawEvents < ActiveRecord::Migration
  def change
  	add_column :raw_events, :cover_image, :text
  end
end
