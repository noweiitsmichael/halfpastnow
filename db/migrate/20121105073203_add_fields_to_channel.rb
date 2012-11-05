class AddFieldsToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :start_date, :datetime
    add_column :channels, :end_date, :datetime
  end
end
