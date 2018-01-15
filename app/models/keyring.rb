#
# Keyring
#
# A collection of cryptographic keys.
#

class Keyring
  class Error < RuntimeError
  end

  def initialize(storage)
    @storage = storage
  end

  def create(type, value)
    raise Error, "key already exists" if storage.keys[type].present?
    storage.set_key type, {type: type, value: value, rev: new_rev}.to_json
    storage.save
  end

  def update(type, rev:, value:)
    old_rev = key_of_type(type)['rev']
    raise Error, "wrong revision: #{rev}" unless old_rev == rev
    storage.set_key type, {type: type, value: value, rev: new_rev}.to_json
    storage.save
  end

  def key_of_type(type)
    JSON.parse(storage.keys[type])
  end

  protected
  attr_reader :storage

  def new_rev
    SecureRandom.urlsafe_base64(8)
  end
end
