class AddFieldsToChannels < ActiveRecord::Migration
  def change
  	remove_column :channels, :start
  	remove_column :channels, :end
  	add_column :channels, :start_seconds, :integer
  	add_column :channels, :end_seconds, :integer
  	add_column :channels, :start_days, :integer
  	add_column :channels, :end_days, :integer
  end
end
