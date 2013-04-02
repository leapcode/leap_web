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

  test "token checks for user" do
    sample = Token.new
    assert !sample.valid?, "Token should require a user record"
  end

end
