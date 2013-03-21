class AddRefColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ref, :string
  end
end
