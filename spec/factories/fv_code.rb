FactoryBot.define do
  factory :fv_code do
    code { "CKVFO5ZTA7" }

    trait :with_cr_group do
      association :fv_codable, factory: :cr_group
      fv_codable_type { 'CrGroup' }
    end

    trait :with_cr_access_data do
      association :fv_codable, factory: :cr_access_data
      fv_codable_type { 'CrAccessData' }
    end
  end
end

