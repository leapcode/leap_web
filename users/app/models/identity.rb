class Identity < CouchRest::Model::Base

  use_database :identities

  belongs_to :user

  property :address, LocalEmail
  property :destination, Email

  validate :unique_forward
  validate :alias_available

  design do
    view :by_user_id
    view :by_address_and_destination
    view :by_address
  end

  protected

  def unique_forward
    same = Identity.find_by_address_and_destination([address, destination])
    if same && same != self
      errors.add :base, "This alias already exists"
    end
  end

  def alias_available
    same = Identity.find_by_address(address)
    if same && same.user != self.user
      errors.add :base, "This email has already been taken"
    end
  end

end
