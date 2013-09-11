class AddWeightToAct < ActiveRecord::Migration
  def change
    add_column :acts, :weight, :integer, :default => 1
  end
end
