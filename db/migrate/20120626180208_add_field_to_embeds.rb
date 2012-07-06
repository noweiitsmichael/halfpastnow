class AddFieldToEmbeds < ActiveRecord::Migration
  def change
  	remove_column :embeds, :source
  	add_column :embeds, :source, :text
  end
end
