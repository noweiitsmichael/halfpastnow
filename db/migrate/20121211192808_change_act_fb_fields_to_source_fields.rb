class ChangeActFbFieldsToSourceFields < ActiveRecord::Migration
  def up
  	rename_column :acts, :fb_id, :pop_id
  	rename_column :acts, :fb_likes, :pop_likes
  	rename_column :acts, :fb_link, :pop_link
  	add_column :acts, :pop_source, :string
  end

  def down
  	rename_column :acts, :pop_id, :fb_id
  	rename_column :acts, :pop_likes, :fb_likes
  	rename_column :acts, :pop_link, :fb_link
  	remove_column :acts, :pop_source
  end
end
