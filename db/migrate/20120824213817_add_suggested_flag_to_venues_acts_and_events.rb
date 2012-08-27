class AddSuggestedFlagToVenuesActsAndEvents < ActiveRecord::Migration
  def change
    add_column :venues, :suggested, :boolean
    add_column :acts, :suggested, :boolean
    add_column :events, :suggested, :boolean
  end
end

