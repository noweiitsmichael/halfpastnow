class AddIndexes < ActiveRecord::Migration
  def up
  	add_index(:occurrences, :start, :unique => false)
  	add_index(:bookmarks, :bookmarked_id)
  	add_index(:bookmarks, :bookmarked_type)
  	add_index(:bookmarks, :bookmark_list_id)
  	add_index(:events, :title)
  	add_index(:bookmark_lists, [:user_id, :main_bookmarks_list])
  	add_index(:bookmark_lists, :featured)
  	add_index(:events, :clicks, :unique => false)
  	add_index(:events, :views, :unique => false)
  end

  def down
  	remove_index(:occurrences, :start, :unique => false)
  	remove_index(:bookmarks, :bookmarked_id)
  	remove_index(:bookmarks, :bookmarked_type)
  	remove_index(:bookmarks, :bookmark_list_id)
  	remove_index(:events, :title)
  	remove_index(:bookmark_lists, [:user_id, :main_bookmarks_list])
  	remove_index(:bookmark_lists, :featured)
  	remove_index(:events, :clicks, :unique => false)
  	remove_index(:events, :views, :unique => false)
  end
end
