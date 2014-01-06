class AddHoursToVenues < ActiveRecord::Migration
  def change
  	add_column :venues, :hours, :text
  end
end
