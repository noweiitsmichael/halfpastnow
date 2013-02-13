class AddTicketUrlToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :ticket_url, :text
  end
end
