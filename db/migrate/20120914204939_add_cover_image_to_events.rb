class AddCoverImageToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :cover_image, :text
  end
end
