require_relative '../../test_helper'
require_relative 'srp_test'

class SignupTest < SrpTest

  setup do
    register_user
  end

  test "signup response" do
    assert_json_response :login => @login, :ok => true, :is_admin => false, :id => @user.id, :enabled => true
    assert last_response.successful?
  end

  test "signup creates user" do
    assert @user
    assert_equal @login, @user.login
  end
end

