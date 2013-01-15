class UpdateVenuesAdminOwnerToInt < ActiveRecord::Migration
  def up
  	add_column :venues, :assigned_admin, :integer
  end

  def down
  	remove_column :venues, :assigned_admin
  end
end
