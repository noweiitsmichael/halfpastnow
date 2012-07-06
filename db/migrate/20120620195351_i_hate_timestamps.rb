class IHateTimestamps < ActiveRecord::Migration
  def change
  	remove_index  :acts_events, :act_id
    remove_index  :acts_events, :event_id
  	drop_table :acts_events
  	create_table :acts_events, :id => false, :force => true do |t|
      t.integer :act_id
      t.integer :event_id
    end
    add_index  :acts_events, :act_id
    add_index  :acts_events, :event_id
  end
end
