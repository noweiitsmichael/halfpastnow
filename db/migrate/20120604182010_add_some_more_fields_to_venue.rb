class AddSomeMoreFieldsToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :events_url, :string
  end
end
