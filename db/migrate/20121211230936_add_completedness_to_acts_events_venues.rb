class AddCompletednessToActsEventsVenues < ActiveRecord::Migration
  def change
  	add_column :acts, :completion, :float
  	add_column :venues, :completion, :float
  	add_column :events, :completion, :float
  end
end
