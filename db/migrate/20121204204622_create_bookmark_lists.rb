class CreateBookmarkLists < ActiveRecord::Migration
  def change
    create_table :bookmark_lists do |t|
		t.text :description
		t.string :custom_url
		t.string :picture
		t.boolean :public
		t.boolean :featured
		t.string :sponsor
		t.timestamps
    end
  end
end
