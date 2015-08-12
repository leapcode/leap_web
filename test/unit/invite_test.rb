require 'test_helper'

class InviteTest < ActiveSupport::TestCase

  test 'check for expiry' do
    recent = Invite.create expiry: 1.days.ago
    future = Invite.create expiry: 1.days.from_now
    assert recent.expired?
    assert ! future.expired?
    recent.destroy
    future.destroy
  end

  test 'cleanup expired' do
    old = Invite.create expiry: 1.month.ago
    recent = Invite.create expiry: 1.days.ago
    future = Invite.create expiry: 2.days.from_now
    Invite.expired(2.days.ago).each(&:destroy)
    assert_destroyed old
    assert_equal recent, recent.reload
    Invite.expired.each(&:destroy)
    assert_destroyed recent
    assert_equal future, future.reload
    Invite.expired(3.days.from_now).each(&:destroy)
    assert_destroyed future
  end

  test 'create with defaults' do
    invite = Invite.create
    assert invite.valid?
    assert invite.persisted?
    assert invite.expiry <= Invite::DEFAULT_DAYS_EXPIRY.days.from_now
    assert invite.code.present?
    assert_equal Invite::DEFAULT_COUNT, invite.count
    invite.destroy
  end

  test 'load from code' do
    invite = Invite.create
    assert_equal invite, Invite.find_by_code(invite.code)
    invite.destroy
  end

  # find_by_property returns nil while reload raises ResourceNotFound.
  test 'invalid invite' do
    assert_nil Invite.find_by_code('asdf')
  end

  def assert_destroyed(invite)
    assert_raises RestClient::ResourceNotFound do
      invite.reload
    end
  end
end
