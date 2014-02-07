require 'test_helper'

class SessionTest < BrowserIntegrationTest

  setup do
    @username, password = submit_signup
  end

  teardown do
    user = User.find_by_login(@username)
    id = user.identity
    id.destroy
    user.destroy
  end

  test "valid session" do
    assert page.has_content?("Welcome #{@username}")
  end

  test "expired session" do
    assert page.has_content?("Welcome #{@username}")
    pretend_now_is(Time.now + 40.minutes) do
      visit '/'
      assert page.has_no_content?("Welcome #{@username}")
    end
  end
end
