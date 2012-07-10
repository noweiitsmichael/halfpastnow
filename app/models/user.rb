class User < ActiveRecord::Base
  attr_accessible :profilepic, :remote_profilepic_url, :crop_x, :crop_y, :crop_w, :crop_h
  mount_uploader :profilepic, ProfilepicUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_profilepic

  has_many :events


  # Cropping functions

  def crop_profilepic
     # puts "trying to crop...crop_X: "
     # puts crop_x
     # puts crop_x.present?
     # might need this line for S3?
    # profilepic.cache_stored_file!
    if crop_x.present?
      profilepic.recreate_versions!
    end
  end

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  validates_presence_of :firstname, :lastname, :username, :email
  validates_uniqueness_of :email, :username, :case_sensitive => false
  
  
	rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :firstname, :lastname, :username, :email, :password, :password_confirmation, :remember_me
end
