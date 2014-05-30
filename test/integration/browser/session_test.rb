require 'test_helper'

class SessionTest < BrowserIntegrationTest

  test "valid session" do
    login
    assert page.has_content?("Log Out")
  end

  test "expired session" do
    login
    pretend_now_is(Time.now + 80.minutes) do
      visit '/'
      assert page.has_content?("Log In")
    end
  end
end
