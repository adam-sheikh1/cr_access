FactoryBot.define do
  factory :vaccination_user do
    relation_ship { 'Parent' }
    user

    trait :with_vaccination_record do
      vaccination_record { build(:vaccination_record) }
    end
  end
end
