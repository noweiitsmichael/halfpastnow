class CreateHistories < ActiveRecord::Migration
  def up
    create_table :histories do |t|
  		t.integer :occurrence_id
  		t.integer :user_id
      t.timestamps
    end
  end

  def down
    drop_table :histories
  end
end
