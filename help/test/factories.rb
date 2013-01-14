FactoryGirl.define do

  factory :ticket do
    title { Faker::Lorem.sentence }
    comments_attributes do
      { "0" => { "body" => Faker::Lorem.sentences } }
    end
  end

end
