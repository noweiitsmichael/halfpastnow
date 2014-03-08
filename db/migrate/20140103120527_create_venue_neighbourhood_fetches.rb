class CreateVenueNeighbourhoodFetches < ActiveRecord::Migration
  def change
    create_table :venue_neighbourhood_fetches do |t|
      t.date :start_date
      t.integer :count

      t.timestamps
    end
  end
end
