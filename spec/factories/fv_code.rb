FactoryBot.define do
  factory :fv_code do
    code { "CKVFO5ZTA7" }
    association :fv_codable, factory: :cr_group

    trait :with_cr_group do
      association :fv_codable, factory: :cr_group
    end

    trait :with_cr_access_data do
      association :fv_codable, factory: :cr_access_data
    end
  end
end

