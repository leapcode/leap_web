require 'login_format_validation'
require 'local_email'
#
# Identity states:
#
#   DISABLED -- An identity is disabled if and only if its associated user
#               is also disabled. In the disabled state, incoming email
#               should bounce and outgoing email should not be relayed.
#
#   ORPHANED -- An identity is orphaned if it has lost its association
#               with a user account. This is in order to keep the name
#               reserved to prevent anyone else from using it.
#

class Identity < CouchRest::Model::Base
  include LoginFormatValidation

  use_database :identities

  belongs_to :user

  property :address, LocalEmail
  property :destination, Email
  property :keys, HashWithIndifferentAccess
  property :cert_fingerprints, Hash
  property :disabled_cert_fingerprints, Hash
  property :enabled, TrueClass, :default => true

  validates :address, presence: true
  validate :address_available
  validates :destination, presence: true, if: :user_id
  validates :destination, uniqueness: {scope: :address}
  validate :address_local_email
  validate :destination_email

  design do
    own_path = Pathname.new(File.dirname(__FILE__))
    load_views(own_path.join('..', 'designs', 'identity'), nil)
    view :by_user_id
    view :by_address_and_destination
    view :by_address
  end

  def self.address_starts_with(query)
    self.by_address.startkey(query).endkey(query + "\ufff0")
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

  # currently leap_mx ignores enabled property, so we
  # also disable the fingerprints instead of just marking
  # identity as disabled.

  def disable!
    self.disabled_cert_fingerprints = self.cert_fingerprints
    self.cert_fingerprints = {}
    self.write_attribute(:enabled, false)
    self.save
  end

  def enable!
    self.cert_fingerprints = self.disabled_cert_fingerprints
    self.disabled_cert_fingerprints = nil
    self.write_attribute(:enabled, true)
    self.save
  end

  # removes the association between this identity and the user.
  def orphan!
    self.destination = nil
    self.user_id = nil
    self.disable!
  end

  def self.destroy_all_orphaned
    Identity.orphaned.each do |identity|
      identity.destroy
    end
  end

  def self.attributes_from_user(user)
    { user_id: user.id,
      address: user.email_address,
      destination: user.email_address
    }
  end

  def status
    if !enabled? || orphaned?
      return :blocked
    else
      case destination
      when address
        :main_email
      when /@#{APP_CONFIG[:domain]}\Z/i,
        :alias
      else
        :forward
      end
    end
  end

  def actions
    if !orphaned?
      [] # [:show, :edit]
    else
      [:destroy]
    end
  end

  def keys
    read_attribute('keys') || HashWithIndifferentAccess.new
  end

  def set_key(type, key_hash)
    key_hash.stringify_keys! if key_hash.respond_to? :stringify_keys!
    return if keys[type] == key_hash
    write_attribute('keys', keys.merge(type => key_hash))
  end

  def delete_key(type)
    raise 'key not found' unless keys[type]
    write_attribute('keys', keys.except(type))
  end

  def cert_fingerprints
    read_attribute('cert_fingerprints') || Hash.new
  end

  def register_cert(cert)
    expiry = cert.expiry.to_date.to_s
    write_attribute 'cert_fingerprints',
      cert_fingerprints.merge(cert.fingerprint => expiry)
  end

  # for LoginFormatValidation
  def login
    address.handle if address.present?
  end

  def orphaned?
    self.user_id.nil?
  end

  def self.orphaned
    # the "disabled" view is a misnomer. it returns
    # identities that have been orphaned, not identities that
    # have been disabled.
    # TODO: fix the view name
    Identity.disabled
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
