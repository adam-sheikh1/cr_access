FactoryBot.define do
  factory :cr_group do
    name { Faker::Name.name }
    group_type { CrGroup::TYPES.keys.sample }
    user
  end
end
