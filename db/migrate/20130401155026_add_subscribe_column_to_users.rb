class AddSubscribeColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribe, :boolean
  end
end
