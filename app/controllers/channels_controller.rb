require 'pp'

class ChannelsController < ApplicationController

	def create
		@channel = Channel.new

		@channel.user_id = current_user.id
		@channel.option_day = params[:option_day].to_s.empty? ? nil : params[:option_day].to_i
		@channel.start_days = params[:start_days].to_s.empty? ? nil : params[:start_days].to_i
		@channel.end_days = params[:end_days].to_s.empty? ? nil : params[:end_days].to_i
		@channel.start_seconds = params[:start_seconds].to_s.empty? ? nil : params[:start_seconds].to_i
		@channel.end_seconds = params[:end_seconds].to_s.empty? ? nil : params[:end_seconds].to_i
		@channel.low_price = params[:low_price].to_s.empty? ? nil : params[:low_price].to_i
		@channel.high_price = params[:high_price].to_s.empty? ? nil : params[:high_price].to_i
		@channel.included_tags = params[:included_tags].to_s.empty? ? nil : params[:included_tags] * ","
		@channel.excluded_tags = params[:excluded_tags].to_s.empty? ? nil : params[:excluded_tags] * ","
		@channel.sort = params[:sort].to_s.empty? ? nil : params[:sort].to_i
		@channel.name = params[:name]

		respond_to do |format|
		  if @channel.save
		    format.html { redirect_to :back }
		    format.json { render json: @channel, status: :created, location: @channel }
		  else
		    format.html { redirect_to :back }
		    format.json { render json: @channel.errors, status: :unprocessable_entity }
		  end
		end
	end

	def new
		@channels = current_user.channels
	    respond_to do |format|
	      format.html { render :layout => "mode_lite" }
	      format.json { render json: @channel }
	    end
	end

	def new2
		@channels = current_user.channels
	    respond_to do |format|
	      format.html { render :layout => "mode_lite" }
	      format.json { render json: @channel }
	    end
	end

	def show
    @channel = Channel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @channel }
    end
  end

	def update
		@channel = Channel.find(params[:id])

		@channel.user_id = current_user.id
		@channel.option_day = params[:option_day].to_s.empty? ? nil : params[:option_day].to_i
		@channel.start_days = params[:start_days].to_s.empty? ? nil : params[:start_days].to_i
		@channel.end_days = params[:end_days].to_s.empty? ? nil : params[:end_days].to_i
		@channel.start_seconds = params[:start_seconds].to_s.empty? ? nil : params[:start_seconds].to_i
		@channel.end_seconds = params[:end_seconds].to_s.empty? ? nil : params[:end_seconds].to_i
		@channel.low_price = params[:low_price].to_s.empty? ? nil : params[:low_price].to_i
		@channel.high_price = params[:high_price].to_s.empty? ? nil : params[:high_price].to_i
		@channel.included_tags = params[:included_tags].to_s.empty? ? nil : params[:included_tags] * ","
		@channel.excluded_tags = params[:excluded_tags].to_s.empty? ? nil : params[:excluded_tags] * ","
		@channel.sort = params[:sort].to_s.empty? ? nil : params[:sort].to_i
		@channel.name = params[:name]

	    respond_to do |format|
	      if @channel.save
	        format.json { render json: @channel }
	      else
		    format.json { render json: @channel.errors, status: :unprocessable_entity }
	      end
	    end
	end


  def destroy
    @channel = channel.find(params[:id])
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  def rename(channel, new_name)
  	channel.name = new_name
  end

end
