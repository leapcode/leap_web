require 'base64'
require 'securerandom'

class InviteCode < CouchRest::Model::Base
  use_database 'invite_codes'
  property :invite_code, String, :read_only => true
  property :invite_count, Integer, :default => 0, :accessible => true
  property :max_uses, Integer, :default => 1

  timestamps!

  design do
    view :by_invite_code
    view :by_invite_count
  end

  def initialize(attributes = {}, options = {})
    super(attributes, options)
    write_attribute('invite_code', generate_invite) if new?

  end

  def generate_invite
    Base64.encode64(SecureRandom.random_bytes).downcase.gsub(/[0oil1+_\/]/,'')[0..7].scan(/..../).join('-')
  end

  def set_invite_code(code)
    write_attribute(:invite_code, code)
  end
end


