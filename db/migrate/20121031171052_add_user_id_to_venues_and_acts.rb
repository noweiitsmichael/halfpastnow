class AddUserIdToVenuesAndActs < ActiveRecord::Migration
  def change
  	add_column :venues, :updated_by, :string
  	add_column :acts, :updated_by, :string
  end
end
