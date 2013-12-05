class CreateAdvertisements < ActiveRecord::Migration
  def change
    create_table :advertisements do |t|
      t.string :type
      t.datetime :start
      t.datetime :end
      t.integer :views
      t.integer :clicks
      t.string :image
      t.string :title
      t.text :description
      t.integer :weight
      t.string :placement
      t.string :name
      t.string :advertiser
      t.string :email
      t.integer :phone
      t.timestamps
    end
  end
end
