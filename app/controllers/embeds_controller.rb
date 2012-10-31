require "pp"
class EmbedsController < ApplicationController
   def index
    @embeds = Embed.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @embeds }
    end
  end

  def create
    puts "Embed Create"
    pp params
    @embed = Embed.new(params[:embeds])

    respond_to do |format|
      if @embed.save
        format.html { render :nothing => true }
        format.json { render json: @embed }
      else
        format.html { render :nothing => true }
        format.json { render json: @embed }
      end
    end
  end

  def new
    @embed = Embed.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @embed }
    end
  end

  def delete
    puts "embed delete"
    @embed = Embed.find(params[:id])
    @embed.destroy

    respond_to do |format|
      format.html 
      format.json { head :ok }
    end
  end

end
