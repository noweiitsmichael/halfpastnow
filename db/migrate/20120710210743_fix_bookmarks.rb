class FixBookmarks < ActiveRecord::Migration
  def up
  	change_table :bookmarks do |t|
  		t.references :bookmarked, :polymorphic => true
  		t.remove :event_id
  	end
  end

  def down
  	change_table :bookmarks do |t|
  		t.remove_references :bookmarked, :polymorphic => true
  		t.integer :event_id
    end
  end
end
