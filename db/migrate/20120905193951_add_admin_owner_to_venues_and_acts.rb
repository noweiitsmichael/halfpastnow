class AddAdminOwnerToVenuesAndActs < ActiveRecord::Migration
  def change
  	add_column :venues, :admin_owner, :string
  	add_column :acts, :admin_owner, :string
  end
end
