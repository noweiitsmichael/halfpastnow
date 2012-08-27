class AddDeleteFlagToOccurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :deleted, :boolean
  end
end
