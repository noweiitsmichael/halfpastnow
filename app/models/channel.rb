class Channel < ActiveRecord::Base
  belongs_to :user

  def self.default_channels
  	return Channel.where(:default => true)
  end
end
