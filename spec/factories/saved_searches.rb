# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :saved_search do
    search_key "MyString"
    user_id 1
  end
end
