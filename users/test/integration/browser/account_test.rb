require 'test_helper'

class AccountTest < BrowserIntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "normal account workflow" do
    username = "test_#{SecureRandom.urlsafe_base64}".downcase
    password = SecureRandom.base64
    visit '/users/new'
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_on 'Sign Up'
    assert page.has_content?("Welcome #{username}")
    click_on 'Logout'
    assert page.has_content?("Sign Up")
    assert_equal '/', current_path
  end

end
