class PicturesController < ApplicationController
	def create
    @picture = Picture.new(params[:picture])
    respond_to do |format|
      if @picture.save
        format.html 
        format.json 
      else
        format.html 
        format.json 
      	end
		format.js
	end
end
