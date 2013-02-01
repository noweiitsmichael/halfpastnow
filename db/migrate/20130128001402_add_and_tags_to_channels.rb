class AddAndTagsToChannels < ActiveRecord::Migration
  def change
  	add_column :channels, :and_tags, :string
  end
end
