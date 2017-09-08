require 'test_helper'

class AccountLivecycleTest < BrowserIntegrationTest

  include ActionView::Helpers::SanitizeHelper

  teardown do
    Identity.destroy_all_orphaned
  end

  test "signup successfully when invited" do
    username, password = submit_signup
    assert_successful_login username
    click_on 'Log Out'
    assert page.has_content?("Log In")
    assert_equal '/', current_path
    assert user = User.find_by_login(username)
    user.account.destroy
  end

  test "signup successfully without invitation" do
    with_config invite_required: false do

      username ||= "test_#{SecureRandom.urlsafe_base64}".downcase
      password ||= SecureRandom.base64

      visit '/signup'
      fill_in 'Username', with: username
      fill_in 'Password', with: password, match: :prefer_exact
      fill_in 'Password confirmation', with: password
      click_on 'Sign Up'

      assert_successful_login username
    end
  end

  test "signup with username ending in dot json" do
    username = Faker::Internet.user_name + '.json'
    submit_signup username
    assert_successful_login username
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
    assert_successful_login username
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

  test "handle available after non blocking account destruction" do
    username, password = submit_signup
    click_on I18n.t('account_settings')
    uncheck I18n.t('keep_username_blocked')
    click_on I18n.t('destroy_my_account')
    submit_signup(username)
    assert_successful_login username
  end

  test "change pgp key" do
    with_config user_actions: ['change_pgp_key'] do
      pgp_key = FactoryGirl.build :pgp_key
      username, _password = submit_signup
      click_on "Account Settings"
      within('#update_pgp_key') do
        fill_in 'Public key', with: pgp_key
        click_on 'Save'
      end
      page.assert_selector 'input[value="Saving..."]'
      # at some point we're done:
      page.assert_no_selector 'input[value="Saving..."]'
      assert page.has_field? 'Public key', with: pgp_key.to_s
      assert_equal pgp_key, User.find_by_login(username).public_key
    end
  end

  def attempt_login(username, password)
    click_on 'Log In'
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    click_on 'Log In'
  end

  def assert_invalid_login(page)
    assert page.has_selector? '.btn-primary.disabled'
    assert page.has_content? sanitize(I18n.t(:invalid_user_pass), tags: [])
    assert page.has_no_selector? '.btn-primary.disabled'
  end

  def assert_successful_login(username)
    assert page.has_content?("Welcome #{username}")
  end
end
