require 'test_helper'

class OsDetectionTest < BrowserIntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "old windows shows deactivated download" do
    page.driver.headers = { "User-Agent" => "Win98" }
    visit '/'
    assert_selector "html.oldwin"
    assert has_text? "not available"
  end

  test "android shows android download" do
    page.driver.headers = { "User-Agent" => "Android" }
    visit '/'
    assert_selector "html.android"
    assert has_no_text? "not available"
    assert_selector "small", text: "Android"
  end

end
