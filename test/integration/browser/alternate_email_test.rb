require 'test_helper'

class AlternateEmailTest < BrowserIntegrationTest
  test "change alternate email" do
    username, password = submit_signup
    click_on 'Account Settings'
    within(".edit_user") do
      fill_in 'user_contact_email', with: 'test@leap.se'
      click_on 'Save'
    end
    assert page.has_content?('Changes saved successfully')
    assert_equal 'test@leap.se',
      page.find('#user_contact_email').value
  end

  test "change alternate email to invalid" do
    username, password = submit_signup
    click_on 'Account Settings'
    within(".edit_user") do
      fill_in 'user_contact_email', with: 'test@invalid'
      click_on 'Save'
      assert page.has_content?('is invalid')
    end
  end
end
