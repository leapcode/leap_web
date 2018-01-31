#
# Keyring
#
# A collection of cryptographic keys.
#

class Keyring
  class Error < RuntimeError
  end

  class NotFound < Error
    def initialize(type)
      super "no such key: #{type}"
    end
  end

  def initialize(storage)
    @storage = storage
  end

  def create(type, value)
    raise Error, "key already exists" if storage.keys[type].present?
    storage.set_key type, {type: type, value: value, rev: new_rev}
    storage.save
  end

  def update(type, rev:, value:)
    check_rev type, rev
    storage.set_key type, {type: type, value: value, rev: new_rev}
    storage.save
  end

  def delete(type, rev:)
    check_rev type, rev
    storage.delete_key type
    storage.save
  end

  def key_of_type(type)
    storage.keys[type]
  end

  protected
  attr_reader :storage

  def check_rev(type, rev)
    old = key_of_type(type)
    raise NotFound, type unless old
    # We used to store plain strings. It's deprecated now.
    # If we happen to run into them do not check their revision.
    return if old.is_a? String
    raise Error, "wrong revision: #{rev}" unless old['rev'] == rev
  end

  def new_rev
    SecureRandom.urlsafe_base64(8)
  end
end
