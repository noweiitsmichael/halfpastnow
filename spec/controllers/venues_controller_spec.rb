require 'spec_helper'

describe VenuesController do
  before(:each) do
    @user = FactoryGirl.build(:user)
  end
  describe "POST #edit" do
    context " profile pic for the user" do
      it "user must have to be login" do
        @user.should_not be_nil
      end
      it "if user exists with or with out profile pic " do
        unless @user.profilepic or @user.fb_picture
          puts "profile or fb picture not defined"
        else
          puts "default image is taken for non registered user"
        end
      end
    end
  end
end