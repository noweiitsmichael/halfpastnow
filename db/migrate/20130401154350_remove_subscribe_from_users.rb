class RemoveSubscribeFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :subscribe
      end

  def down
    add_column :users, :subscribe, :string
  end
end
