class Cert < CouchRest::Model::Base

  use_database 'client_certificates'

  timestamps!

  property :random, Float, :accessible => false

  before_validation :set_random, :attach_zip, :on => :create

  validates :random, :presence => true,
    :numericality => {:greater_than => 0, :less_than => 1}

  validates :zip_attachment, :presence => true

  design do
    view :by_random
  end

  class << self
    def sample
      self.by_random.startkey(rand).first || self.by_random.first
    end

    def pick_from_pool
      cert = self.sample || self.create!
      cert.destroy
      return cert
    rescue RESOURCE_NOT_FOUND
      retry if Cert.by_random.count > 0
      raise RECORD_NOT_FOUND
    end

  end

  def set_random
    self.random = rand
  end

  def attach_zip
    file = File.open(Rails.root.join("config", "cert"))
    self.create_attachment :file => file, :name => zipname
  end

  def zipname
    'cert.txt'
  end

  def zip_attachment
    attachments[zipname]
  end

  def zipped
    read_attachment(zipname)
  end

end
