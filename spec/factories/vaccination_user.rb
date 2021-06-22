FactoryBot.define do
  factory :vaccination_user do
    relation_ship { 'Parent' }
    user
    vaccination_record
  end
end
