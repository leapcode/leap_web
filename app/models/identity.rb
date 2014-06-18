class Identity < CouchRest::Model::Base
  include LoginFormatValidation

  use_database :identities

  belongs_to :user

  property :address, LocalEmail
  property :destination, Email
  property :keys, HashWithIndifferentAccess
  property :cert_fingerprints, Hash

  validates :address, presence: true
  validate :address_available
  validates :destination, presence: true, if: :enabled?
  validates :destination, uniqueness: {scope: :address}
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
    id = find_by_address_and_destination attributes.values_at(:address, :destination)
    return id if id && id.user == user
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
      # if the identity is not unique anymore because the destination
      # was reset to nil we destroy it.
      identity.save || identity.destroy
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
    self.user_id
  end

  def disabled?
    !enabled?
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

  def cert_fingerprints
    read_attribute('cert_fingerprints') || Hash.new
  end

  def register_cert(cert)
    today = DateTime.now.to_date.to_s
    write_attribute 'cert_fingerprints',
      cert_fingerprints.merge(cert.fingerprint => today)
  end

  # for LoginFormatValidation
  def login
    address.handle if address.present?
  end

  protected

  def address_available
    blocking_identities = Identity.by_address.key(address).all
    blocking_identities.delete self
    if self.user
      blocking_identities.reject! { |other| other.user == self.user }
    end
    if blocking_identities.any?
      errors.add :address, :taken
    end
  end

  def address_local_email
    # caught by presence validation
    return if address.blank?
    return if address.valid?
    address.errors.each do |attribute, error|
      self.errors.add(:address, error)
    end
  end

  def destination_email
    # caught by presence validation or this identity is disabled
    return if destination.blank?
    return if destination.valid?
    destination.errors.each do |attribute, error|
      self.errors.add(:destination, error)
    end
  end

  ActiveSupport.run_load_hooks(:identity, self)
end
