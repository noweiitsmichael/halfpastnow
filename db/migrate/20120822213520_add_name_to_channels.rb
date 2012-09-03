class AddNameToChannels < ActiveRecord::Migration
  def change
  	add_column :channels, :name, :string
  end
end
