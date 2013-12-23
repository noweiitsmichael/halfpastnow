class Advertisement < ActiveRecord::Base
  attr_accessible :adv_type, :title, :description,:name, :email, :phone,:advertiser
  attr_accessible :image, :weight, :placement, :start,:end, :views, :clicks
  belongs_to :user

  mount_uploader :image, AdvertisementUploader

  validates :adv_type, :title, :description,:name,:advertiser, presence: true
  validates :image, :weight, :placement, :start,:end , presence: true

  ADV_TYPES = [["Featured Venue","featured_venue"],["Featured Event","featured_event"],["Featured Artist","featured_artist"],["Advertisement","advertisement"]]
  ADV_PLACEMENTS = [["Home Page","home_page"],["Search Results","search_results"],["Event Details","event_details"],["Venue Details","venue_details"],["Artist Details","artist_details"]]
  ADV_WEIGHTS = [1,2,3,4,5,6,7,8,9,10]
end
