require 'test_helper'

class PasswordValidationTest < BrowserIntegrationTest

  test "password confirmation is validated" do
    password = SecureRandom.base64
    submit_signup_form password: password, confirmation: password + 'a'
    assert page.has_content? "does not match."
    assert_equal '/signup', current_path
    assert_error_for 'srp_password_confirmation'
  end

  test "password needs to be at least 8 chars long" do
    submit_signup_form password: SecureRandom.base64[0,7]
    assert page.has_content? "needs to be at least 8 characters long"
    assert_equal '/signup', current_path
    assert_error_for 'srp_password'
  end

  def submit_signup_form(username: nil, password: nil, confirmation: nil)
    username ||= "test_#{SecureRandom.urlsafe_base64}".downcase
    password ||= SecureRandom.base64
    confirmation ||= password
    visit '/signup'
    fill_in 'Username', with: username
    fill_in 'Password', with: password, match: :prefer_exact
    fill_in 'Password confirmation', with: confirmation
    click_on 'Sign Up'
  end

  def assert_error_for(id)
    assert page.has_selector? ".has-error ##{id}"
  end
end
