FactoryBot.define do
  factory :vaccination_record do
    clinic_name { Faker::Job.title }
    clinic_location { Faker::Job.title }
    dose_volume { '1' }
    dose_volume_units { '1' }
    external_id { '12' }
    lot_number { Faker::Number.number }
    manufacturer_name { Faker::Job.title }
    reaction { Faker::Job.title }
    route { 'IM' }
    site { 'LT' }
    vaccination_date { DateTime.now }
    vaccine_name { Faker::Job.title }
    cr_access_data_id { }
    vaccine_expiration_date { rand.to_s[1..2].to_i.years.from_now }
    cr_access_data

    trait :with_vaccination_users do
      vaccination_users { build_list(:vaccination_user, 2) }
    end
  end
end
