class AddCoverImageToRawEvents < ActiveRecord::Migration
  def up
  	add_column :raw_events, :cover_image, :text
  end

  def down
  	change_column :raw_events, :cover_image, :integer
  end
end
