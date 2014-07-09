require 'test_helper'

class AdminTest < BrowserIntegrationTest

  test "clear blocked handle" do
    id = FactoryGirl.create :identity
    submit_signup(id.login)
    assert page.has_content?('has already been taken')
    login
    with_config admins: [@user.login] do
      visit '/'
      click_on "Usernames"
      fill_in 'query', with: id.login[0]
      click_on "Search"
      within "##{dom_id(id)}" do
        assert page.has_content? id.login
        click_on "Destroy"
      end
      fill_in 'query', with: id.login[0]
      click_on "Search"
      assert page.has_no_content? id.login
      click_on 'Log Out'
    end
    submit_signup(id.login)
    assert page.has_content?("Welcome #{id.login}")
    click_on 'Log Out'
  end
end
