class CreateBookmarkListsUsers < ActiveRecord::Migration
  def change
    create_table :bookmark_lists_users, :id => false, :force => true do |t|
      t.integer :bookmark_list_id
      t.integer :user_id
      t.timestamps
    end
    add_index  :bookmark_lists_users, :bookmark_list_id
    add_index  :bookmark_lists_users, :user_id
  end
end
