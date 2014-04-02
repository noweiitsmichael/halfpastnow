class AddWeightToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :weight, :integer, :default => 1
  end
end
