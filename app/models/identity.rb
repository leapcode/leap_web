class Identity < CouchRest::Model::Base
  include LoginFormatValidation

  use_database :identities

  belongs_to :user

  property :address, LocalEmail
  property :destination, Email
  property :keys, HashWithIndifferentAccess
  property :cert_fingerprints, [String]

  validate :unique_forward
  validate :alias_available
  validate :address_local_email
  validate :destination_email

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
        if (typeof doc.keys === "object") {
          emit(doc.address, doc.keys["pgp"]);
        }
      }
    EOJS
    view :disabled,
      map: <<-EOJS
      function(doc) {
        if (doc.type != 'Identity') {
          return;
        }
        if (typeof doc.user_id === "undefined") {
          emit(doc._id, 1);
        }
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

  def self.disable_all_for(user)
    Identity.by_user_id.key(user.id).each do |identity|
      identity.disable
      identity.save
    end
  end

  def self.destroy_all_for(user)
    Identity.by_user_id.key(user.id).each do |identity|
      identity.destroy
    end
  end

  def self.destroy_all_disabled
    Identity.disabled.each do |identity|
      identity.destroy
    end
  end

  def self.attributes_from_user(user)
    { user_id: user.id,
      address: user.email_address,
      destination: user.email_address
    }
  end

  def enabled?
    self.destination && self.user_id
  end

  def disable
    self.destination = nil
    self.user_id = nil
  end

  def keys
    read_attribute('keys') || HashWithIndifferentAccess.new
  end

  def set_key(type, key)
    return if keys[type] == key.to_s
    write_attribute('keys', keys.merge(type => key.to_s))
  end

  # for LoginFormatValidation
  def login
    self.address.handle
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

  def address_local_email
    return if address.valid? #this ensures it is LocalEmail
    self.errors.add(:address, address.errors.messages[:email].first) #assumes only one error
  end

  def destination_email
    return if destination.nil?   # this identity is disabled
    return if destination.valid? # this ensures it is Email
    self.errors.add(:destination, destination.errors.messages[:email].first) #assumes only one error #TODO
  end

end
