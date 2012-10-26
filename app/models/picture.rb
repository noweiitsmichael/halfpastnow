class Picture < ActiveRecord::Base
  #attr_accessible :image, :remote_image_url
  belongs_to :pictureable, :polymorphic => true
  mount_uploader :image, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_image

  def crop_image
    puts "crop_image"
     # might need this line for S3?
    # profilepic.cache_stored_file!
    if crop_x.present?
      image.recreate_versions!
    end
  end
  # def image=(val)
  #   if !val.is_a?(String) && valid?
  #     image_will_change!
  #     super
  #   end
  # end

end
