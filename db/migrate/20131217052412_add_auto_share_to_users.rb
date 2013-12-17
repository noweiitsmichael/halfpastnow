class AddAutoShareToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auto_share, :boolean, default: true
  end
end
