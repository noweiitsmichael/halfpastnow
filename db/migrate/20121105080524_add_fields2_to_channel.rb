class AddFields2ToChannel < ActiveRecord::Migration
  def change
    remove_column :channels, :start_date
    remove_column :channels, :end_date
    add_column :channels, :start_date, :date
    add_column :channels, :end_date, :date
  end
end
