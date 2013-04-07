class CreateEmailTable < ActiveRecord::Migration
  def up
  	create_table :emails do |t|
  		t.string :email
  	end
  end

  def down
  	drop_table :emails
  end
end
