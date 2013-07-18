class LocalEmail < Email


  def self.domain
    APP_CONFIG[:domain]
  end

  validates :email,
    :format => {
      :with => /@#{domain}\Z/i,
      :message => "needs to end in @#{domain}"
    }

  def initialize(s)
    super
    append_domain_if_needed
  end

  def to_key
    [handle]
  end

  def handle
    gsub(/@#{domain}/i, '')
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

end
