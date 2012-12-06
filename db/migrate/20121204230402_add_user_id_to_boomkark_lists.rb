class AddUserIdToBoomkarkLists < ActiveRecord::Migration
  def change
  	add_column :bookmark_lists, :user_id, :integer
  end
end
