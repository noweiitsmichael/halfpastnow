class CreateSavedSearches < ActiveRecord::Migration
  def change
    create_table :saved_searches do |t|
      t.string :search_key
      t.integer :tag_id
      t.integer :user_id

      t.timestamps
    end
  end
end
