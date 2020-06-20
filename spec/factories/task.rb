FactoryBot.define do
  factory :task do
    name { 'テストをかく' }
    description { 'Rspec&Capybara&FactoryBotを準備する' }
    user
  end
end