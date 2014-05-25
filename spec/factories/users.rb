# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.safe_email }
    password "password"
    password_confirmation "password"
    admin false
  end
end
