FactoryGirl.define do

  factory :ticket do
    title { Faker::Lorem.sentence }
    email { Faker::Internet.email }

    factory :ticket_with_comment do
      comments_attributes do
        { "0" => { "body" => Faker::Lorem.sentences.join(" ") } }
      end
    end
  end

end
