class IHateTimestamps2 < ActiveRecord::Migration
  def change
  	remove_index  :acts_tags, :act_id
    remove_index  :acts_tags, :tag_id
  	drop_table :acts_tags
  	create_table :acts_tags, :id => false, :force => true do |t|
      t.integer :act_id
      t.integer :tag_id
    end
    add_index  :acts_tags, :act_id
    add_index  :acts_tags, :tag_id
  end
end
