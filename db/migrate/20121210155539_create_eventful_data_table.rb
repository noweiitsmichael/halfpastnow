class CreateEventfulDataTable < ActiveRecord::Migration
  def change
    create_table :eventful_data do |t|
		t.string :eventful_origin_type
		t.string :eventful_origin_id
		t.integer :element_id
		t.string :element_type
		t.string :data_type
		t.text :data
		t.text :data2
		t.text :data3
		t.text :data4
		t.timestamps
    end
  end
end
