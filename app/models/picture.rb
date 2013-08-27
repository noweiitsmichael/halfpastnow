class Picture < ActiveRecord::Base
  belongs_to :pictureable, :polymorphic => true
  # mount_uploader :image, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_image

  def crop_image
    # puts "crop_image"

    if crop_x.present?
      image.recreate_versions!
    end
  end

end
