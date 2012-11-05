class AddFields3ToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :search, :text
  end
end
