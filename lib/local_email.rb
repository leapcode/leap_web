require 'email'
class LocalEmail < Email

  BLACKLIST_FROM_RFC2142 = [
    'postmaster', 'hostmaster', 'domainadmin', 'webmaster', 'www',
    'abuse', 'noc', 'security', 'usenet', 'news', 'uucp',
    'ftp', 'sales', 'marketing', 'support', 'info'
  ]

  def self.domain
    APP_CONFIG[:domain]
  end

  validates :email,
    :format => {
      :with => /@#{domain}\Z/i,
      :message => "needs to end in @#{domain}"
    }

  validate :handle_allowed

  def initialize(s)
    super
    append_domain_if_needed
  end

  def to_key
    [handle]
  end

  def domain
    LocalEmail.domain
  end

  protected

  def append_domain_if_needed
    unless self.index('@')
      self << '@' + domain
    end
  end

  def handle_allowed
    errors.add(:handle, "is reserved.") if handle_reserved?
  end

  def handle_reserved?
    # *ARRAY in a case statement tests if ARRAY includes the handle.
    case handle
    when *APP_CONFIG[:handle_blacklist]
      true
    when *APP_CONFIG[:handle_whitelist]
      false
    when *BLACKLIST_FROM_RFC2142
      true
    else
      handle_in_passwd?
    end
  end

  def handle_in_passwd?
    Etc.getpwnam(handle).present?
  rescue ArgumentError
    # handle was not found
    return false
  end
end
