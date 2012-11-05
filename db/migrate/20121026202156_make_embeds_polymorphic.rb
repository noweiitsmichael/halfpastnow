class MakeEmbedsPolymorphic < ActiveRecord::Migration
  def up
  	rename_column :embeds, :act_id, :embedable_id
  	add_column :embeds, :embedable_type, :string
  end

  def down
  	rename_column :embeds, :embedable_id, :act_id
  	remove_column :embeds, :embedable_type
  end
end
