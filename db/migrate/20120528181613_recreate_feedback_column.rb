class RecreateFeedbackColumn < ActiveRecord::Migration
  def up
    remove_column :feedbacks, :feedback_type
    add_column :feedbacks, :fdbk_cat, :string
  end

  def down
    remove_column :feedbacks, :fdbk_cat
    add_column :feedbacks, :feedback_type, :integer
  end
end
