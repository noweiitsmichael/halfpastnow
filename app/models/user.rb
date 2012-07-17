class User < ActiveRecord::Base
  attr_accessible :profilepic, :remote_profilepic_url, :crop_x, :crop_y, :crop_w, :crop_h
  mount_uploader :profilepic, ProfilepicUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_profilepic

  has_many :events

  # Allows you to search for bookmarked venues/events/acts by calling "user.bookmarked_type"
  has_many :bookmarks  
  has_many :bookmarked_venues, :through =>  :bookmarks, :source => :bookmarked, :source_type => "Venue"
  has_many :bookmarked_events, :through =>  :bookmarks, :source => :bookmarked, :source_type => "Occurrence"
  has_many :bookmarked_acts, :through =>  :bookmarks, :source => :bookmarked, :source_type => "Act"
  # has_many :bookmarked_all, :through => :bookmarks, :source => :bookmarked, :source_type => 

  # History (attended events)
  has_many :histories, :dependent => :destroy
  has_many :occurrences, :through => :histories


  # Cropping function
  def crop_profilepic
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
