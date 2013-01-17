FactoryGirl.define do

  factory :ticket do
    title { Faker::Lorem.sentence }
    comments_attributes do
      { "0" => { "body" => Faker::Lorem.sentences.join(" ") } }
    end
  end

end
