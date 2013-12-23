class AddTargetUrlToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :target_url, :string
  end
end
