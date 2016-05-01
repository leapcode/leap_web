require 'test_helper'

class SecurityTest < BrowserIntegrationTest

  teardown do
    Identity.destroy_all_orphaned
  end

  # trying to seed an invalid A for srp login
  test "detects attempt to circumvent SRP" do
    InviteCodeValidator.any_instance.stubs(:validate)

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
    Api::UsersController.any_instance.stubs(:create).raises
    submit_signup
    assert page.has_content?("server failed")
  end

  test "does not render signup form without js" do
    Capybara.current_driver = :rack_test # no js
    visit '/signup'
    assert page.has_no_content?("Username")
    assert page.has_no_content?("Password")
  end

  test "does not render login form without js" do
    Capybara.current_driver = :rack_test # no js
    visit '/login'
    assert page.has_no_content?("Username")
    assert page.has_no_content?("Password")
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
