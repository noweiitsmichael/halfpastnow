class AddTempStorageToActsVenues < ActiveRecord::Migration
  def change
  	add_column :acts, :temp_storage, :text
  	add_column :raw_venues, :temp_storage, :text
  end
end
