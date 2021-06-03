FactoryBot.define do
  factory :user do
    password = Faker::Internet.password(min_length: 10)
    email { Faker::Internet.email }
    password { password }
    password_confirmation { password }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    confirmed_at { Date.today }
    phone_number { '5417543010' }
    date_of_birth { rand.to_s[3..4].to_i.years.ago }
  end
end
