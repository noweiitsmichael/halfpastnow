class CreateActsEvents < ActiveRecord::Migration
  def change
    create_table :acts_events, :id => false, :force => true do |t|
      t.integer :act_id
      t.integer :event_id
      t.timestamps
    end
    add_index  :acts_events, :act_id
    add_index  :acts_events, :event_id
  end
end
