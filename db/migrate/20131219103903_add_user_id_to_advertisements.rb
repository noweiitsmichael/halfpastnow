class AddUserIdToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :user_id, :integer
  end
end
