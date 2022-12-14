FactoryBot.define do
  factory :user do
    name { 'Michael Example' }
    email { 'michael@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
  end
  
  factory :archer do
    name { 'Sterling Archer' }
    email { 'duchess@example.gov' }
    password { 'password' }
    password_confirmation { 'password' }
  end
  
  factory :lana do
    name { 'Lana Kane' }
    email { 'hands@example.gov' }
    password { 'password' }
    password_confirmation { 'password' }
  end
  
  factory :melory do
    name { 'Malory Archer' }
    email { 'boss@example.gov' }
    password { 'password' }
    password_confirmation { 'password' }
  end
  
  factory :continuous_users, class: User do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
