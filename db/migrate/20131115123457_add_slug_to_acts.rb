class AddSlugToActs < ActiveRecord::Migration
  def change
    add_column :acts, :slug, :string
  end
end
