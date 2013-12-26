class NeighborhoodsVenues < ActiveRecord::Migration
  def up
    create_table :neighborhoods_venues, id:false do |t|
      t.integer :neighborhood_id
      t.integer :venue_id
    end
  end

  def down
    drop_table :neighborhoods_venues
  end
end
