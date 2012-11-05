class Channel < ActiveRecord::Base
  belongs_to :user

  def self.default_channels
  	return Channel.where(:default => true)
  end

  def update_custom(params)
	self.start_days = params[:start_days].to_s.empty? ? nil : params[:start_days].to_i
	self.end_days = params[:end_days].to_s.empty? ? nil : params[:end_days].to_i
	self.start_seconds = params[:start_seconds].to_s.empty? ? nil : params[:start_seconds].to_i
	self.end_seconds = params[:end_seconds].to_s.empty? ? nil : params[:end_seconds].to_i
	self.low_price = params[:low_price].to_s.empty? ? nil : params[:low_price].to_i
	self.high_price = params[:high_price].to_s.empty? ? nil : params[:high_price].to_i
	self.included_tags = params[:included_tags].to_s.empty? ? nil : params[:included_tags] * ","
	self.excluded_tags = params[:excluded_tags].to_s.empty? ? nil : params[:excluded_tags] * ","
	self.day_of_week = params[:day].to_s.empty? ? nil : params[:day] * ","
	self.start_date = params[:start_date].to_s.empty? ? nil : Date.parse(params[:start_date])
	self.end_date = params[:end_date].to_s.empty? ? nil : Date.parse(params[:end_date])
	self.search = params[:search].to_s.empty? ? nil : params[:search]
	self.name = params[:name]
  end
end
