class User < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :username, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :fb_access_token
  attr_accessible :profilepic, :remote_profilepic_url, :crop_x, :crop_y, :crop_w, :crop_h
  mount_uploader :profilepic, ProfilepicUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_profilepic


  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false

  has_many :events
  has_many :channels
  has_many :acts, :foreign_key => :updated_by
  has_many :venues, :foreign_key => :assigned_admin

  # Allows you to search for bookmarked venues/events/acts by calling "user.bookmarked_type"
  has_and_belongs_to_many :followedLists, :class_name => "BookmarkList", :join_table => "bookmark_lists_users"
  has_many :bookmark_lists
  # has_many :bookmarks  
  # has_many :bookmarked_venues, :through => :bookmarks, :source => :bookmarked, :source_type => "Venue"
  # has_many :bookmarked_events, :through => :bookmarks, :source => :bookmarked, :source_type => "Occurrence"
  # has_many :bookmarked_acts, :through => :bookmarks, :source => :bookmarked, :source_type => "Act"
  #has_many :followed_lists, :through => :bookmarks, :source => :bookmarked, :source_type => "Bookmark List"

  # History (attended events)
  has_many :histories, :dependent => :destroy
  has_many :occurrences, :through => :histories

  # Friending
  has_many :friendships
  has_many :friends, :through => :friendships

  ROLES = %w[admin super_admin]

  after_create :send_welcome_email
  after_create :send_contest_entry_email
  after_create :create_default_list


  # Cropping function
  def crop_profilepic
    # puts "crop profilepic"
     # might need this line for S3?
    # profilepic.cache_stored_file!
    if crop_x.present?
      profilepic.recreate_versions!
    end
  end


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
        if (channel.name == "Happy Hours") || (channel.name == "Live Music") || (channel.name == "Fitness") || (channel.name == "Shows") || (channel.name == "Nightlife") 
          new_channel = channel.dup
          new_channel.id = nil
          new_channel.default = nil
          user.channels << new_channel
        end
      end
    end
    return user
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(fb_access_token)
  end


  def fullname
    return firstname + " " + lastname
  end

  def assigned_events
    # Events from assigned venues that will happen in the next 2 months
    total_events = 0;
    self.venues.each do |v|
      total_events += v.events.select { |oc| oc.nextOccurrence ? (oc.nextOccurrence.start < 2.months.from_now) : nil}.count
    end
    return total_events
  end

  def assigned_raw_events
    # Raw Events from assigned venues that will happen in the next 2 months
    total_events = 0;
    self.venues.each do |v|
      total_events += v.raw_venues.collect { |rv| rv.raw_events }.flatten.select{ |re| !(re.deleted || re.submitted) && (re.start > Time.now) && (re.start < 2.months.from_now)}.count
    end
    return total_events
  end

  def total_raw_events
    # Raw Events from assigned venues that will happen in the next 2 months
    total_events = 0;
    self.venues.each do |v|
      total_events += v.raw_venues.collect { |rv| rv.raw_events }.flatten.select{ |re| !(re.deleted || re.submitted) && (re.start > Time.now)}.count
    end
    return total_events
  end

  def total_activity_week
    total_activity = 0;
    total_activity += Event.find(:all, :conditions => ["(user_id = ?) AND (updated_at > ?)", self.id, 168.hours.ago]).count
    total_activity += Venue.find(:all, :conditions => ["(updated_by = ?) AND (updated_at > ?)", self.id, 168.hours.ago]).count
    total_activity += Act.find(:all, :conditions => ["(updated_by = ?) AND (updated_at > ?)", self.id, 168.hours.ago]).count
    return total_activity
  end

  def bookmarked_venues
    return BookmarkList.where(:user_id => self.id, :main_bookmarks_list => true).first.bookmarked_venues
  end

  def bookmarked_acts
    return BookmarkList.where(:user_id => self.id, :main_bookmarks_list => true).first.bookmarked_acts
  end

  def bookmarked_events
    return BookmarkList.where(:user_id => self.id, :main_bookmarks_list => true).first.all_bookmarked_events
  end

  def main_bookmark_list
    return BookmarkList.where(:user_id => self.id, :main_bookmarks_list => true).first
  end

  def featured_list
    return BookmarkList.where(:user_id => self.id, :featured => true).first
  end

  def attending_list
    return BookmarkList.where(:user_id => self.id, :name => "Attending").first
  end

  def attending_events
    return BookmarkList.where(:user_id => self.id, :name => "Attending").first.all_bookmarked_events
  end

  def bookmarking_events
    return BookmarkList.where(:user_id => self.id, :name => "Attending").first.all_bookmarked_events
  end

  def send_welcome_email
    puts "send_welcome_email"
    self.subscribe = true
    self.save
    # Making friends for FB users
    unless self.fb_access_token.nil?
      unless self.uid.nil?
        # puts "FB User !!!!!"
        query ="select uid, name from user where is_app_user = 1 and uid in (SELECT uid2 FROM friend WHERE uid1 = me())"
        @facebook ||= Koala::Facebook::API.new(self.fb_access_token) 
        @f=@facebook.fql_query(query)
        # puts @f
        @myfriends = self.friends
        @fs = @myfriends.collect{|f| f.uid.to_s}
        uids = @f.collect{|p| p["uid"].to_s}
       
        # puts ufs
        # puts uids
        ufs = uids - @fs
        puts "The set: "
        puts ufs
        urs = User.find_all_by_uid(ufs)
        if urs.size > 0
          urs.each{|ur|
            friendship= self.friendships.build(:friend_id => ur.id)
            friendship.save!  
          }  
        end
      end
    end
    



    unless self.email.include?('@halfpastnow.com') && Rails.env != 'test'
      UserMailer.welcome_email(self).deliver
    end
  end

   def send_welcome_email
    unless self.email.include?('@halfpastnow.com') && Rails.env != 'test'
      UserMailer.contest_entry_email(self).deliver
    end
  end


  def create_default_list
    puts "to email list"
    e=Email.new
    e.email=self.email
    e.save
    puts "creating default list"

    BookmarkList.create(:name => "Bookmarks", :description => "Bookmarks", :public => false, 
                        :featured => false, :main_bookmarks_list => true, :user_id => self.id)
    puts "creating default attending list"
    BookmarkList.create(:name => "Attending", :description => "Attending", :public => false, 
                        :featured => false, :main_bookmarks_list => false, :user_id => self.id)

    # Follow all top picks lists
    BookmarkList.where(:featured => true).find_each do |top_list|
      BookmarkListsUsers.create(:bookmark_list_id => top_list.id, :user_id => self.id)
    end
  end


  def self.role_list 
    return ["guest","user","top_picker","admin","super_admin"]
  end

  def role_at_least? (title)
    if(!User.role_list.index(title) || !User.role_list.index(self.role))
      return false
    else
      return (User.role_list.index(self.role) >= User.role_list.index(title))
    end

  end

  # def password_required?
  #   super && provider.blank?
  # end
end
