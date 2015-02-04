class Invite < CouchRest::Model::Base

  use_database :invites

  property :code, String
  property :count, Integer
  property :expiry, Time

  validates :code,
    presence: true,
    uniqueness: true

  DEFAULT_DAYS_EXPIRY = 30
  DEFAULT_COUNT = 1

  def initialize(*args)
    super
    opts = args.extract_options!
    self.code = SecureRandom.hex   # TODO: replace this with something useful
    self.count = opts[:count] || DEFAULT_COUNT
    self.expiry = opts[:expiry] || DEFAULT_DAYS_EXPIRY.days.from_now
  end

  design do
    view :by_code
    view :by_expiry
    view :by_count
  end

  def self.expired(expiry = Time.now)
    by_expiry.endkey(expiry)
  end

  def expired?(time = Time.now)
    expiry < time
  end

end
