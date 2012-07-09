class CreateActsTags < ActiveRecord::Migration
  def change
    create_table :acts_tags, :id => false, :force => true do |t|
      t.integer :act_id
      t.integer :tag_id
      t.timestamps
    end
    add_index  :acts_tags, :act_id
    add_index  :acts_tags, :tag_id
  end
end
