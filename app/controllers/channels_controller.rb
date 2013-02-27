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

   def index
    @channel = Channel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @channels }
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

		if(@channel.user != current_user)
	    	respond_to { |format| format.json { render json: @channel.errors, status: :unprocessable_entity } }
	    end

		@channel.update_custom(params)
		

	    respond_to do |format|
	      if @channel.save
	        format.json { render json: @channel }
	      else
		    format.json { render json: @channel.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def rename
		@channel = Channel.find(params[:id])

		if(@channel.user != current_user)
	    	respond_to { |format| format.json { render json: @channel.errors, status: :unprocessable_entity } }
	    end

		@channel.update_attributes(params[:stream])
		

	    respond_to do |format|
	      if @channel.save
	        format.json { render json: @channel }
	      else
		    format.json { render json: @channel.errors, status: :unprocessable_entity }
	      end
	    end
	end

  def destroy
  	@channel = Channel.find(params[:id])

    if(@channel.user != current_user)
    	respond_to { |format| format.json { render json: @channel.errors, status: :unprocessable_entity } }
    end

    respond_to do |format|
	    if @channel.destroy
	    	format.json { render json: @channel }
		else
			format.json { render json: @channel.errors, status: :unprocessable_entity }
		end
	end
  end

end
