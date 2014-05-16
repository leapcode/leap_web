require 'test_helper'

class PasswordValidationTest < BrowserIntegrationTest

  test "password confirmation is validated" do
    username ||= "test_#{SecureRandom.urlsafe_base64}".downcase
    password ||= SecureRandom.base64
    visit '/users/new'
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password + "-typo"
    click_on 'Sign Up'
    assert page.has_content? "does not match."
    assert_equal '/users/new', current_path
    assert page.has_selector? ".error #srp_password_confirmation"
  end

  test "password needs to be at least 8 chars long" do
    username ||= "test_#{SecureRandom.urlsafe_base64}".downcase
    password ||= SecureRandom.base64[0,7]
    visit '/users/new'
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_on 'Sign Up'
    assert page.has_content? "needs to be at least 8 characters long"
    assert_equal '/users/new', current_path
    assert page.has_selector? ".error #srp_password"
  end
end

