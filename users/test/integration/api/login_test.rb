require 'test_helper'

class LoginTest < RackTest

  setup do
    @login = "integration_test_user"
  end

  test "require json requests" do
    put "http://api.lvh.me:3000/1/sessions/" + @login,
      :client_auth => "This is not a valid login anyway"
    assert_json_error login: I18n.t(:all_strategies_failed)
  end

end
