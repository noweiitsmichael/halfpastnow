class ChangeUpdatedByToInteger < ActiveRecord::Migration
  def up
  	remove_column :acts, :updated_by
  	remove_column :venues, :updated_by
  	add_column :acts, :updated_by, :integer
  	add_column :venues, :updated_by, :integer
  end

  def down
  	remove_column :acts, :updated_by
  	remove_column :venues, :updated_by
  	add_column :acts, :updated_by, :string
  	add_column :venues, :updated_by, :string
  end
end
