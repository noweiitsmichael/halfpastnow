class AddIndicesToEventsTags < ActiveRecord::Migration
  def change
  	add_index  :events_tags, :event_id
  	add_index  :events_tags, :tag_id
  end
end
