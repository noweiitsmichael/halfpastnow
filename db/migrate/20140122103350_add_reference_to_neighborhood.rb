class AddReferenceToNeighborhood < ActiveRecord::Migration
  def change
    add_column :neighborhoods, :reference, :text
  end
end
