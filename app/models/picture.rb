class Picture < ActiveRecord::Base
  #attr_accessible :image, :remote_image_url
  belongs_to :pictureable, :polymorphic => true
  mount_uploader :image, ImageUploader
  

  # def image=(val)
  #   if !val.is_a?(String) && valid?
  #     image_will_change!
  #     super
  #   end
  # end

end
