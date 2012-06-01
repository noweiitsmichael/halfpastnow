class RenameTypeToFeedbackType < ActiveRecord::Migration
  def up
    rename_column :feedbacks, :type, :feedback_type
  end

  def down
    rename_column :feedbacks, :feedback_type, :type
  end
end
