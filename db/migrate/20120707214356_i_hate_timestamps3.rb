class IHateTimestamps3 < ActiveRecord::Migration
  def change
  	remove_index  :events_tags, :event_id
    remove_index  :events_tags, :tag_id
  	drop_table :events_tags
  	create_table :events_tags, :id => false, :force => true do |t|
      t.integer :event_id
      t.integer :tag_id
    end
    add_index  :events_tags, :event_id
    add_index  :events_tags, :tag_id
  end
end
