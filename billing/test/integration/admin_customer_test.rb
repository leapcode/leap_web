require 'test_helper'
require 'fake_braintree'

class AdminCustomerTest < BraintreeIntegrationTest

  setup do
    @admin = User.find_by_login('admin') || FactoryGirl.create(:user, login: 'admin')
    @user = FactoryGirl.create(:user)
  end

  teardown do
    @user.destroy if @user
    @admin.destroy if @admin
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
    skip "cannot check customer as admin"
    # it would be good to have a test where an admin tries to view the 'Billing Settings' for another user.
    # However, partially due to limitations of FakeBraintree, this doesn't seem pursuing at this time.
  end
end
