class AddFields2ToRawVenue < ActiveRecord::Migration
  def change
    add_column :raw_venues, :events_url, :string
    add_column :raw_venues, :last_visited, :datetime
  end
end
