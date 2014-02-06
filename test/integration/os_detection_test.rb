require 'test_helper'

class OsDetectionTest < BrowserIntegrationTest

  test "old windows shows deactivated download" do
    page.driver.add_headers "User-Agent" => "Win98"
    visit '/'
    assert_selector "html.oldwin"
    assert has_text? "not available"
  end

  test "android shows android download" do
    page.driver.add_headers "User-Agent" => "Android"
    visit '/'
    assert_selector "html.android"
    assert has_no_text? "not available"
    assert_selector "small", text: "Android"
  end

end
