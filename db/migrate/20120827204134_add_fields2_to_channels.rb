class AddFields2ToChannels < ActiveRecord::Migration
  def change
  	add_column :channels, :default, :boolean
  end
end
