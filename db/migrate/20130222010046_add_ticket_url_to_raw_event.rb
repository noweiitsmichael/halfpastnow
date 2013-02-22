class AddTicketUrlToRawEvent < ActiveRecord::Migration
  def change
  	add_column :raw_events, :ticket_url, :text
  end
end
