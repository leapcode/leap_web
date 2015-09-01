require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  include StubRecordHelper

  setup do
    InviteCodeValidator.any_instance.stubs(:validate)
    @user = find_record :user
  end

  test "new token for user" do
    sample = Token.new(:user_id => @user.id)
    assert sample.valid?
    assert_equal @user.id, sample.user_id
    assert_equal @user, sample.authenticate
  end

  test "token is secure" do
    sample = Token.new(:user_id => @user.id)
    other = Token.new(:user_id => @user.id)
    assert sample.token,
      "token is set on initialization"
    assert sample.token[0..10] != other.token[0..10],
      "token prefixes should not repeat"
    assert /[g-zG-Z]/.match(sample.token),
      "should use non hex chars in the token"
    assert sample.token.size > 16,
      "token should be more than 16 chars long"
  end

  test "token id is hash of the token" do
    sample = Token.new(:user_id => @user.id)
    assert_equal Digest::SHA512.hexdigest(sample.token), sample.id
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

  test "Token.destroy_all_expired is noop if no expiry is set" do
    expired = FactoryGirl.create :token, last_seen_at: 2.hours.ago
    with_config auth: {} do
      Token.destroy_all_expired
    end
    assert_equal expired, Token.find(expired.id)
  end

  test "Token.destroy_all_expired cleans up expired tokens only" do
    expired = FactoryGirl.create :token, last_seen_at: 2.hours.ago
    fresh = FactoryGirl.create :token
    with_config auth: {token_expires_after: 60} do
      Token.destroy_all_expired
    end
    assert_nil Token.find(expired.id)
    assert_equal fresh, Token.find(fresh.id)
    fresh.destroy
  end


  test "Token.destroy_all_expired does not interfere with expired.authenticate" do
    expired = FactoryGirl.create :token, last_seen_at: 2.hours.ago
    with_config auth: {token_expires_after: 60} do
      Token.destroy_all_expired
    end
    assert_nil expired.authenticate
  end

end
