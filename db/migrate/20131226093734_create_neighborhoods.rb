class CreateNeighborhoods < ActiveRecord::Migration
  def change
    create_table :neighborhoods do |t|
      t.string :city
      t.string :name
      t.string :state
      t.string :state_code
      t.string :country
      t.string :country_code
      t.string :url

      t.timestamps
    end
  end
end
