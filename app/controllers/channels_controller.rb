require 'pp'

class ChannelsController < ApplicationController

	def create
		puts params;
		@channel = Channel.new
		@channel.update_attributes(params[:channel])
		@channel.tags = params[:channel][:tags]
		#@channel = Channel.new(params[:channel])
		@channel.user_id = current_user.id

		pp @channel
		respond_to do |format|
		  if @channel.save
		    format.html { redirect_to :back }
		    format.json { render json: @channel, status: :created, location: @channel }
		  else
		    format.html { redirect_to :back }
		    format.json { render json: @channel.errors, status: :unprocessable_entity }
		  end
		  format.js
		end
	end

	def new
	    @channel = Channel.new

	    respond_to do |format|
	      format.html # new.html.erb
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
	    respond_to do |format|
	      if @channel.update_attributes(params[:channel])
	        format.html { redirect_to @user, notice: 'Channel was successfully updated.' }
	        format.json { head :no_content }
	      else
	        format.html { render action: "edit" }
	        format.json { render json: @user.errors, status: :unprocessable_entity }
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
