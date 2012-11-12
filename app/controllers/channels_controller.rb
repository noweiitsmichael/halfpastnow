require 'pp'

class ChannelsController < ApplicationController

	def create
		@channel = current_user.channels.build
		@channel.update_custom(params)

		respond_to do |format|
		  if @channel.save
		    format.html { redirect_to :back }
		    format.json { render json: @channel }
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
		@channel.update_custom(params)
		

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
