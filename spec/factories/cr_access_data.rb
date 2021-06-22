FactoryBot.define do
  factory :cr_access_data do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { ['male', 'female', 'other'].sample }
    address { Faker::Address.full_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { Faker::Address.zip_code }
    phone_number { '4042335006' }
    date_of_birth { rand.to_s[3..4].to_i.years.ago }
    prepmod_patient_id { 1 }
    vaccination_status { CrAccessData::VACCINATION_STATUSES.values.sample }
    patient_id { 2 }
  end
end
