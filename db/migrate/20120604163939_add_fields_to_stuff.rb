class AddFieldsToStuff < ActiveRecord::Migration
  def change
  	add_column :acts, :event_id, :integer
  	add_index  :acts, :event_id
    add_column :embeds, :act_id, :integer
  	add_index  :embeds, :act_id
  end
end
