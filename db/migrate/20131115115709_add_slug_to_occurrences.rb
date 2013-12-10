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
    occurrences = Occurrence.all
    missing_occ = []
    occurrences.each do |occ|
      begin
        occ.slug = "#{occ.event.title.truncate(15)}-at-#{occ.event.venue.name.truncate(15)}" rescue nil
        occ.save
      rescue Exception => ex
        missing_occ << occ.id
        puts ex.message
      end
    end

  end
end
