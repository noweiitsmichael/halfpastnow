class Advertisement < ActiveRecord::Base
  attr_accessible :adv_type, :title, :description,:name, :email, :phone,:advertiser
  attr_accessible :image, :weight, :placement, :start,:end, :views, :clicks, :target_url
  belongs_to :user

  mount_uploader :image, AdvertisementUploader

  validates :adv_type, :title, :description,:name,:advertiser, presence: true
  validates :image, :weight, :placement, :start,:end , presence: true

  ADV_TYPES = {"Featured Venue" => "featured_venue","Featured Event" => "featured_event", "Featured Artist" =>"featured_artist", "Advertisement - Banner" => "banner_ads", "Advertisement - Details" =>"details_ads", "Advertisement - List Sidebar" =>"sidebar_ads"}
  ADV_TYPES_SHOW = '{"featured_venue": "Featured Venue", "featured_event": "Featured Event", "featured_artist": "Featured Artist", "banner_ads": "Advertisement - Banner", "details_ads": "Advertisement - Details", "sidebar_ads": "Advertisement - List Sidebar"}'
  ADV_PLACEMENTS = {
                     :featured => [["Home Page","home_page"],["Search Results","search_results"],["Both", "home_search_pages"]],
                     :banner => [["Search Results","search_results"]],
                     :details => [["Details","details"]],
                     :sidebar => [["Sidebar", "sidebar"]]
                   }
  ADV_WEIGHTS = [1,2,3,4,5,6,7,8,9,10]
  ADV_WEIGHTS_SHOW = "{'1': '1','2' : '2' , '3': '3','4': '4','5' : '5','6' :'6','7': '7','8' :'8','9' : '9','10': '10'}"
end