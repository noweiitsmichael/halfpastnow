class AddPrimaryToEmbeds < ActiveRecord::Migration
  def change
    add_column :embeds, :primary, :boolean
  end
end
