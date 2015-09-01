require 'test_helper'

class AccountTest < BrowserIntegrationTest

  teardown do
    Identity.destroy_all_disabled
  end

  test "signup successfully" do
    username, password = submit_signup
    assert page.has_content?("Welcome #{username}")
    click_on 'Log Out'
    assert page.has_content?("Log In")
    assert_equal '/', current_path
    assert user = User.find_by_login(username)
    user.account.destroy
  end

  test "signup with username ending in dot json" do
    username = Faker::Internet.user_name + '.json'
    submit_signup username
    assert page.has_content?("Welcome #{username}")
  end

  test "signup with reserved username" do
    username = 'certmaster'
    submit_signup username
    assert page.has_content?("is reserved.")
  end

  test "successful login" do
    username, password = submit_signup
    click_on 'Log Out'
    attempt_login(username, password)
    assert page.has_content?("Welcome #{username}")
    within('.sidenav li.active') do
      assert page.has_content?("Overview")
    end
    User.find_by_login(username).account.destroy
  end

  test "failed login" do
    visit '/'
    attempt_login("username", "wrong password")
    assert_invalid_login(page)
  end

  test "account destruction" do
    username, password = submit_signup

    click_on I18n.t('account_settings')
    click_on I18n.t('destroy_my_account')
    assert page.has_content?(I18n.t('account_destroyed'))
    assert_equal 1, Identity.by_address.key("#{username}@test.me").count
    attempt_login(username, password)
    assert_invalid_login(page)
  end

  test "handle blocked after account destruction" do
    username, password = submit_signup
    click_on I18n.t('account_settings')
    click_on I18n.t('destroy_my_account')
    submit_signup(username)
    assert page.has_content?('has already been taken')
  end

  test "default user actions" do
    login
    click_on "Account Settings"
    assert page.has_content? I18n.t('destroy_my_account')
    assert page.has_no_css? '#update_login_and_password'
    assert page.has_no_css? '#update_pgp_key'
  end

  test "default admin actions" do
    login
    with_config admins: [@user.login] do
      click_on "Account Settings"
      assert page.has_content? I18n.t('destroy_my_account')
      assert page.has_no_css? '#update_login_and_password'
      assert page.has_css? '#update_pgp_key'
    end
  end

  test "change pgp key" do
    with_config user_actions: ['change_pgp_key'] do
      pgp_key = FactoryGirl.build :pgp_key
      login
      click_on "Account Settings"
      within('#update_pgp_key') do
        fill_in 'Public key', with: pgp_key
        click_on 'Save'
      end
      page.assert_selector 'input[value="Saving..."]'
      # at some point we're done:
      page.assert_no_selector 'input[value="Saving..."]'
      assert page.has_field? 'Public key', with: pgp_key.to_s
      @user.reload
      assert_equal pgp_key, @user.public_key
    end
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
    V1::UsersController.any_instance.stubs(:create).raises
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

  def attempt_login(username, password)
    click_on 'Log In'
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    click_on 'Log In'
  end

  def assert_invalid_login(page)
    assert page.has_selector? '.btn-primary.disabled'
    assert page.has_content? I18n.t(:invalid_user_pass)
    assert page.has_no_selector? '.btn-primary.disabled'
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
