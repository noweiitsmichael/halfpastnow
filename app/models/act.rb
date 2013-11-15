class Act < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name,use: :slugged
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tags
  has_many :pictures, :as => :pictureable, :dependent => :destroy
  has_many :embeds, :as => :embedable, :dependent => :destroy
  #attr_accessible :pictures_attributes, :pictures
  attr_accessor :image, :remote_image_url
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => proc {|attributes| attributes['image'].blank? && attributes['remote_image_url'].blank?  }
  accepts_nested_attributes_for :embeds, :allow_destroy => true
  # So we can assign to admin:
  belongs_to :user

  # Bi-directional bookmarks association (find a user's bookmarked performers, and users who have bookmarked this performer)
  belongs_to :bookmarked, :polymorphic => true
  has_many :bookmarks, :as => :bookmarked, :dependent => :destroy
  # Allows you to search for users that bookmarked this artist by calling "act.bookmarked_by"
  #has_many :bookmarked_by, :through => :bookmarks, :source => :user

  def completedness
  	total_elements = 5
  	complete_elements = 0
  	unless(self.name.to_s.empty?)
  		complete_elements += 1
  	end
  	unless(self.description.to_s.empty?)
  		complete_elements += 1
  	end
  	unless(self.tags.size == 0)
  		complete_elements += 1
  	end
  	unless(self.embeds.size == 0)
  		complete_elements += 1
  	end
    unless(self.pictures.size == 0)
      complete_elements += 1
    end
  	return complete_elements.to_f / total_elements.to_f
  end

  def num_upcoming_events_one_month
    return self.events.map(&:nextOccurrence.to_proc).reject {|x| x.nil?}.delete_if { |x| x.start > 1.month.from_now}.count
  end

 
end
