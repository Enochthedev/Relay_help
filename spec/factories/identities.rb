FactoryBot.define do
  factory :identity do
    user { nil }
    provider { "MyString" }
    uid { "MyString" }
    email { "MyString" }
    name { "MyString" }
    avatar_url { "MyString" }
    raw_info { "" }
  end
end
