require 'pp'

class EmailsController < ApplicationController

  def new
    @email = Email.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email }
    end
  end

  def edit
    @email = email.find(params[:id])
    @email.update_attributes(params[:email])
  end

  def create
    puts "created new email"
    @email = Email.new(params[:email])

    respond_to do |format|
      if @email.save
        format.html { redirect_to @email, notice: 'email was successfully added.' }
        format.json { render json: @email, status: :created, location: @email }
      else
        format.html { render action: "new" }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

end