class RemoveAdminOwnerFromVenue < ActiveRecord::Migration
  def up
  	remove_column :venues, :admin_owner
  end

  def down
  	add_column :venues, :admin_owner, :string
  end
end
