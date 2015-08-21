require 'coupon_code'

class InviteCode < CouchRest::Model::Base
  use_database 'invite_codes'
  property :invite_code, String, :read_only => true
  timestamps!

  design do
    view :by_invite_code
  end

  def initialize(attributes = {}, options = {})
    super(attributes, options)
    write_attribute('invite_code', CouponCode.generate) if new?
  end

end


