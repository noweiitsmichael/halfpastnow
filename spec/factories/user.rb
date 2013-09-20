FactoryGirl.define do
  factory :user do
    email 'hpn@startupsourcing.com'
    password 'password'
    password_confirmation 'password'
    profilepic 'http://hpn-pictures.s3.amazonaws.com/uploads/user/profilepic/1358/IMG_0566.JPG '
  end
end