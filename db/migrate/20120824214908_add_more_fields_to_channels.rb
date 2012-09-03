class AddMoreFieldsToChannels < ActiveRecord::Migration
  def change
  	add_column :channels, :option_day, :integer
  	add_column :channels, :low_price, :integer
  	add_column :channels, :high_price, :integer
  	add_column :channels, :included_tags, :string
   	add_column :channels, :excluded_tags, :string
   	remove_column :channels, :tags
   	remove_column :channels, :price
  end
end
