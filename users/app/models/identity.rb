class Identity < CouchRest::Model::Base

  use_database :identities

  belongs_to :user

  property :address, LocalEmail
  property :destination, Email
  property :keys, HashWithIndifferentAccess

  validate :unique_forward
  validate :alias_available

  design do
    view :by_user_id
    view :by_address_and_destination
    view :by_address
    view :pgp_key_by_email,
      map: <<-EOJS
      function(doc) {
        if (doc.type != 'Identity') {
          return;
        }
        emit(doc.address, doc.keys["pgp"]);
      }
    EOJS

  end

  def self.for(user, attributes = {})
    find_for(user, attributes) || build_for(user, attributes)
  end

  def self.find_for(user, attributes = {})
    attributes.reverse_merge! attributes_from_user(user)
    find_by_address_and_destination [attributes[:address], attributes[:destination]]
  end

  def self.build_for(user, attributes = {})
    attributes.reverse_merge! attributes_from_user(user)
    Identity.new(attributes)
  end

  def self.create_for(user, attributes = {})
    identity = build_for(user, attributes)
    identity.save
    identity
  end

  def self.attributes_from_user(user)
    { user_id: user.id,
      address: user.email_address,
      destination: user.email_address
    }
  end

  def keys
    read_attribute('keys') || HashWithIndifferentAccess.new
  end

  def set_key(type, value)
    return if keys[type] == value
    write_attribute('keys', keys.merge(type => value))
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
