require 'test_helper'

class AdminTest < BrowserIntegrationTest

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

  test "clear blocked handle" do
    id = FactoryBot.create :identity
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
