require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase
  include StubRecordHelper

  setup do
    @user = find_record :user
  end

  teardown do
  end

  test "new token for user" do
    sample = Token.new(:user_id => @user.id)
    assert sample.valid?
    assert_equal @user.id, sample.user_id
    assert_equal @user, sample.authenticate
  end

  test "token id is secure" do
    sample = Token.new(:user_id => @user.id)
    other = Token.new(:user_id => @user.id)
    assert sample.id,
      "id is set on initialization"
    assert sample.id[0..10] != other.id[0..10],
      "token id prefixes should not repeat"
    assert /[g-zG-Z]/.match(sample.id),
      "should use non hex chars in the token id"
    assert sample.id.size > 16,
      "token id should be more than 16 chars long"
  end

  test "token checks for user" do
    sample = Token.new
    assert !sample.valid?, "Token should require a user record"
  end

  test "token updates timestamps" do
    sample = Token.new(user_id: @user.id)
    sample.last_seen_at = 1.minute.ago
    sample.expects(:save)
    assert_equal @user, sample.authenticate
    assert Time.now - sample.last_seen_at < 1.minute, "last_seen_at has not been updated"
  end

  test "token will not expire if token_expires_after is not set" do
    sample = Token.new(user_id: @user.id)
    sample.last_seen_at = 2.years.ago
    with_config auth: {} do
      sample.expects(:save)
      assert_equal @user, sample.authenticate
    end
  end

  test "expired token returns nil on authenticate" do
    sample = Token.new(user_id: @user.id)
    sample.last_seen_at = 2.hours.ago
    with_config auth: {token_expires_after: 60} do
      sample.expects(:destroy)
      assert_nil sample.authenticate
    end
  end

  test "Token.destroy_all_expired cleans up expired tokens only" do
    expired = Token.new(user_id: @user.id)
    expired.last_seen_at = 2.hours.ago
    expired.save
    fresh = Token.new(user_id: @user.id)
    fresh.save
    with_config auth: {token_expires_after: 60} do
      Token.destroy_all_expired
    end
    assert_nil Token.find(expired.id)
    assert_equal fresh, Token.find(fresh.id)
    fresh.destroy
  end




end
