class AddNIdToNeighborhoods < ActiveRecord::Migration
  def change
    add_column :neighborhoods, :n_id, :string
  end
end
