class AddPictureUrlToBookmarkList < ActiveRecord::Migration
  def change
  	add_column :bookmark_lists, :picture_url, :string
  end
end
