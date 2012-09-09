class Picture < ActiveRecord::Base
<<<<<<< HEAD
  attr_accessible :picture
  belongs_to :pictureable, :polymorphic => true
=======
  # belongs_to :pictureable, :polymorphic => true
>>>>>>> 8c0f9207e50090f6a84bb91a376512aee3bc1819

end
