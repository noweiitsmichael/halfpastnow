class AddScoreToEvent < ActiveRecord::Migration
  def change
    add_column :events, :escore, :float, :default => 0
    add_column :events, :weight, :integer, :default => 1
  end
end
