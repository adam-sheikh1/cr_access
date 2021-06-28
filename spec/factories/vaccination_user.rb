FactoryBot.define do
  factory :vaccination_user do
    relationship { 'Parent' }
    user
    vaccination_record
  end
end
