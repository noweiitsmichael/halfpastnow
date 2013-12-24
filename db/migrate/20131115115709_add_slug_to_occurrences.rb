class AddSlugToOccurrences < ActiveRecord::Migration
  def up
    add_column :occurrences, :slug, :string
    add_index :occurrences, :slug
    #update_slug
  end
  def down
    remove_column :occurrences, :slug

  end
  def update_slug
    occurrences = Occurrence.where(:id => 144768..150000)
    occurrences.each do |occ|
        occ.slug = "#{occ.event.title.truncate(20)}-at-#{occ.event.venue.name.truncate(20)}" rescue "#{occ.id}"
        occ.save
    end

  end
end
