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
    view :by_created_at
    view :by_updated_at
  end

  def initialize(attributes = {}, options = {})
    attributes[:id] = attributes["invite_code"] || InviteCode.generate_invite
    super(attributes, options)
    if new?
      write_attribute('invite_code', attributes[:id])
      write_attribute('max_uses', attributes[:max_uses] || 1)
    end
  end

  def self.generate_invite
    Base64.encode64(SecureRandom.random_bytes).downcase.gsub(/[0oil1+_\/]/,'')[0..7].scan(/..../).join('-')
  end
end


