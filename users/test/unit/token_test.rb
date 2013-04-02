require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  teardown do
    @user.destroy
  end

  test "new token for user" do
    sample = Token.new(:user_id => @user.id)
    assert sample.valid?
    assert_equal @user.id, sample.user_id
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

end
