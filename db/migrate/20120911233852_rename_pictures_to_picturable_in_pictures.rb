class RenamePicturesToPicturableInPictures < ActiveRecord::Migration
  def change
  	rename_column :pictures, :picture_id, :pictureable_id
  	rename_column :pictures, :picture_type, :pictureable_type
  end
end
