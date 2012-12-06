class ChangeBookmarkStructure < ActiveRecord::Migration
  def up
  	add_column :bookmarks, :bookmark_list_id, :integer
  	add_column :bookmark_lists, :main_bookmarks_list, :boolean
  end

  def down
  	remove_column :bookmarks, :bookmark_list_id
  	remove_column :bookmark_lists, :main_bookmarks_list
  end
end
