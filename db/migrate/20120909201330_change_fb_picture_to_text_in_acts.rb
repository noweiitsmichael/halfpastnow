class ChangeFbPictureToTextInActs < ActiveRecord::Migration
  def up
  	change_column :acts, :fb_picture, :text
  end

  def down
  	change_column :acts, :fb_picture, :string
  end
end
