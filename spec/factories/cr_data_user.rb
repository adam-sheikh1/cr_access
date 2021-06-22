FactoryBot.define do
  factory :cr_data_user do
    status { CrDataUser::STATUSES.keys.sample }
    data_type { CrDataUser::DATA_TYPES.keys.sample }
    primary { Faker::Boolean.boolean }
    user
    cr_access_data
  end
end
