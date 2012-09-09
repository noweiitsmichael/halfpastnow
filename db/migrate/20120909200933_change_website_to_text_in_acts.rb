class ChangeWebsiteToTextInActs < ActiveRecord::Migration
  def up
  	change_column :acts, :website, :text
  end

  def down
  	change_column :acts, :website, :string
  end
end
