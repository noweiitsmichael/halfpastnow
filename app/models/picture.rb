class Picture < ActiveRecord::Base
  attr_accessible :picture
  # belongs_to :pictureable, :polymorphic => true


end
