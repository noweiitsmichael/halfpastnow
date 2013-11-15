class AddSlugToBookmarkLists < ActiveRecord::Migration
  def change
    add_column :bookmark_lists, :slug, :string
    add_index :bookmark_lists, :slug
  end
end
