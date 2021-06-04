FactoryBot.define do
  factory :qr_code do
    code { "eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiZXhwIjoxNjIyMTI2MTUyfQ.VjCdjbxQVMpyN0uEReh4JsPbPZA1R7tIekg867uGcIY" }

    trait :with_cr_group do
      association :codeable, factory: :cr_group
      codeable_type { 'CrGroup' }
    end

    trait :with_cr_access_data do
      association :codeable, factory: :cr_access_data
      codeable_type { 'CrAccessData' }
    end
  end
end

