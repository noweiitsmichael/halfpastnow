class CreatePictures < ActiveRecord::Migration
   def change
    create_table :pictures do |t|
      t.string :picture
      t.references :picture, :polymorphic => true
      t.timestamps
    end
  end
end
