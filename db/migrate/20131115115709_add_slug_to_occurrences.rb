class AddSlugToOccurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :slug, :string
    add_index :occurrences, :slug
  end
end
