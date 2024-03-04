FactoryBot.define do
  factory :user do
    sequence(:email) { |n| Faker::Internet.email.gsub('@', "-#{n}@") }
    password { 'password123' } # Adjust the password as needed
    name { Faker::Name.name }
  end
end
