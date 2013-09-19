require 'test_helper'

class AccountTest < BrowserIntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "normal account workflow" do
    username, password = submit_signup
    assert page.has_content?("Welcome #{username}")
    click_on 'Logout'
    assert page.has_content?("Sign Up")
    assert_equal '/', current_path
    assert user = User.find_by_login(username)
    user.account.destroy
  end

  test "successful login" do
    username, password = submit_signup
    click_on 'Logout'
    click_on 'Log In'
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    click_on 'Log In'
    assert page.has_content?("Welcome #{username}")
  end

  # trying to seed an invalid A for srp login
  test "detects attempt to circumvent SRP" do
    user = FactoryGirl.create :user
    visit '/login'
    fill_in 'Username', with: user.login
    fill_in 'Password', with: "password"
    inject_malicious_js
    click_on 'Log In'
    assert page.has_content?("Invalid random key")
    assert page.has_no_content?("Welcome")
    user.destroy
  end

  test "reports internal server errors" do
    V1::UsersController.any_instance.stubs(:create).raises
    submit_signup
    assert page.has_content?("server failed")
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
