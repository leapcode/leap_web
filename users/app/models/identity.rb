class Identity < CouchRest::Model::Base

  use_database :identities

  belongs_to :user

  property :address
  property :destination

  def initialize(attribs = {}, &block):q
    attribs.reverse_merge! user_id: user.id,
      address: user.main_email_address,
      destination: user.main_email_address
    Identity.new attribs
  end

  design do
    view :by_user_id
  end
end
