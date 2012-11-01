class User < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :username, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :fb_access_token
  attr_accessible :profilepic, :remote_profilepic_url, :crop_x, :crop_y, :crop_w, :crop_h
  mount_uploader :profilepic, ProfilepicUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_profilepic


  validates_presence_of :firstname, :lastname, :email
  validates_uniqueness_of :email, :username, :case_sensitive => false

  has_many :events
  has_many :channels

  # Allows you to search for bookmarked venues/events/acts by calling "user.bookmarked_type"
  has_many :bookmarks  
  has_many :bookmarked_venues, :through => :bookmarks, :source => :bookmarked, :source_type => "Venue"
  has_many :bookmarked_events, :through => :bookmarks, :source => :bookmarked, :source_type => "Occurrence"
  has_many :bookmarked_acts, :through => :bookmarks, :source => :bookmarked, :source_type => "Act"

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

  rolify


  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable


  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info

    # TODO: if email exists but uid does not, ask user if he wants to merge with existing account

    if user = User.where(:email => data.email).first || User.where(:uid => data.id).first
      if user.fb_access_token.nil?
        user.fb_access_token = access_token.credentials.token
        user.provider = "facebook"
        user.uid = data.id     
        @new_user_token = Koala::Facebook::API.new(access_token.credentials.token)
        user.fb_picture = @new_user_token.get_picture(data.id, :type => "large", :height => "125", :width => "125")
      end

      return user

    # TODO: Check to see if they have signed in before locally?
    else # Create a user with a stub password. 
      new_user = User.create(:email => data.email, 
                   :firstname => data.first_name, 
                   :lastname => data.last_name, 
                   :username => data.username, 
                   :password => Devise.friendly_token[0,20], 
                   :provider => "facebook",
                   :uid => data.id,
                   :fb_access_token => access_token.credentials.token)
      @new_user_token = Koala::Facebook::API.new(new_user.fb_access_token)
      new_user.fb_picture = @new_user_token.get_picture(data.id, :type => "large", :height => "125", :width => "125")
      new_user.save
      return new_user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]

      end
    end
  end


  def self.new(attributes = nil, options = {})
    user = super
    if user
      Channel.default_channels.each do |channel| 
        new_channel = channel.dup
        new_channel.id = nil
        new_channel.default = nil
        user.channels << new_channel
      end
    end
    return user
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(fb_access_token)

  end

  # def password_required?
  #   super && provider.blank?
  # end
end
