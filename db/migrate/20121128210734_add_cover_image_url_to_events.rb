class AddCoverImageUrlToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :cover_image_url, :string
  end
end
