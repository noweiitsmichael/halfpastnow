class AddEventLinkToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :event_url, :text
  end
end
