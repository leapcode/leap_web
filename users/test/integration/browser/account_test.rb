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

  # trying to seed an invalid A for srp login
  test "detects attempt to circumvent SRP" do
    user = FactoryGirl.create :user
    visit '/sessions/new'
    fill_in 'Username', with: user.login
    fill_in 'Password', with: "password"
    inject_malicious_js
    click_on 'Log In'
    assert page.has_content?("Invalid random key")
    assert page.has_no_content?("Welcome")
  end

  def inject_malicious_js
    page.execute_script <<-EOJS
      var calc = new srp.Calculate();
      calc.A = function(_a) {return "00";};
      calc.S = calc.A;
      srp.session = new srp.Session(null, calc);
    EOJS
  end
end
