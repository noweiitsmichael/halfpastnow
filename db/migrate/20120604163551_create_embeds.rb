class CreateEmbeds < ActiveRecord::Migration
  def change
    create_table :embeds do |t|
      t.string :source

      t.timestamps
    end
  end
end
