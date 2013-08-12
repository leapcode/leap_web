require 'test_helper'
require 'fake_braintree'
require 'capybara/rails'

class CustomerCreationTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Capybara::DSL

  setup do
    Warden.test_mode!
    @admin = User.find_by_login('admin') || FactoryGirl.create(:user, login: 'admin')
    @user = FactoryGirl.create(:user)
  end

  teardown do
    Warden.test_reset!
    @user.destroy
    @admin.destroy
  end

  test "check non customer as admin" do
    login_as @admin
    visit '/'
    click_link 'Users'
    click_link @user.login
    click_link 'Billing Settings'
    assert page.has_content? @user.email_address
    assert page.has_content? 'No Saved Customer'
  end

  test "check customer as admin" do
=begin

    login_as @admin
    visit '/'
    click_link 'Users'
    click_link @user.login
    click_link 'Billing Settings'
    assert page.has_content? @user.email_address
    assert !page.has_content?('No Saved Customer')
    save_and_open_page
=end
  end
end
