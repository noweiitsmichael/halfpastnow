class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :type
      t.string :subject
      t.string :description
      t.integer :status
      t.integer :user_id

      t.timestamps
    end
  end
end
