FactoryBot.define do
  factory :cr_access_group do
    status { CrAccessGroup::STATUSES.keys.sample }
    access_level { CrAccessGroup::ACCESS_LEVELS.keys.sample }
    cr_access_data
    cr_group
  end
end
