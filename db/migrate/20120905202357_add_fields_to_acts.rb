class AddFieldsToActs < ActiveRecord::Migration
  def change
  	add_column :acts, :website, :string
  	add_column :acts, :genre, :text
  	add_column :acts, :bio, :text
  	add_column :acts, :fb_id, :string
  	add_column :acts, :fb_likes, :string
  	add_column :acts, :fb_link, :string

  end
end
