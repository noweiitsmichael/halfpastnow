class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.datetime :start
      t.datetime :end
      t.string :price
      t.string :day_of_week
      t.string :tags
      t.timestamps
    end
    add_column :channels, :user_id, :integer
    add_index  :channels, :user_id
  end
end
