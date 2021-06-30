FactoryBot.define do
  factory :share_request do
    user
    status { ShareRequest::STATUSES[:pending] }
    data { Faker::Internet.email }

    trait :public_share do
      data { Faker::Internet.email }
    end

    trait :registered_share do
      association :recipient, factory: :user
      data { recipient.email }
    end
  end
end
