FactoryGirl.define do

  factory :ticket do
    subject { Faker::Lorem.sentence }
    email { Faker::Internet.email }

    factory :ticket_with_comment do
      comments_attributes do
        { "0" => {
          "body" => Faker::Lorem.sentences.join(" "),
          "posted_by" => created_by
        } }
      end
    end

    factory :ticket_with_creator do
      created_by { FactoryGirl.create(:user).id }
    end

  end

  # TicketComments can not be saved. so only use this with build
  # and add to a ticket afterwards
  factory :ticket_comment do
    body { Faker::Lorem.sentences.join(" ") }
  end

end
