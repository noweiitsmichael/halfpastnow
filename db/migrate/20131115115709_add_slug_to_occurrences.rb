class AddSlugToOccurrences < ActiveRecord::Migration
  def up
    add_column :occurrences, :slug, :string
    add_index :occurrences, :slug
    update_slug
  end
  def down
    remove_column :occurrences, :slug

  end
  def update_slug
    occurrences = Occurrence.all

    occurrences.each do |occ|
      occ.slug = "#{occ.event.title.truncate(12)}-at-#{occ.event.venue.name.truncate(12)}" rescue nil
      occ.save
    end

  end
end
