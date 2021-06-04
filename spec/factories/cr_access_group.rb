FactoryBot.define do
  factory :cr_access_group do
    status { CrAccessGroup::STATUSES.keys.sample }
    access_level { CrAccessGroup::ACCESS_LEVELS.keys.sample }

    trait :with_cr_access_data do
      cr_access_data { build(:cr_access_data) }
    end

    trait :with_cr_group do
      cr_group { build(:cr_group) }
    end
  end
end
