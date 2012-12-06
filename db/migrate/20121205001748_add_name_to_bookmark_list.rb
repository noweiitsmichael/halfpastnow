class AddNameToBookmarkList < ActiveRecord::Migration
  def change
    add_column :bookmark_lists, :name, :string
  end
end
