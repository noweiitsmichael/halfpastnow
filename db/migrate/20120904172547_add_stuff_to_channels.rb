class AddStuffToChannels < ActiveRecord::Migration
  def change
  	add_column :channels, :sort, :integer
  end
end
