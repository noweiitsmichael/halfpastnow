class RenamePictureToImageInPictures < ActiveRecord::Migration
  def change
  	rename_column :pictures, :picture, :image
  end
end
