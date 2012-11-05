class AddEventLinkToRawEvent < ActiveRecord::Migration
  def change
  	  add_column :raw_events, :event_url, :text
  end
end
