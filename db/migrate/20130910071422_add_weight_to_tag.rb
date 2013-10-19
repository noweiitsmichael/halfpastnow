class AddWeightToTag < ActiveRecord::Migration
  def change
    add_column :tags, :weight, :integer, :default => 1
  end
end
