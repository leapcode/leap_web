require 'test_helper'

class NavigationTest < BrowserIntegrationTest

  #
  # this is a regression test for #5879
  #
  test "admin can navigate all tickets" do
    login
    with_config admins: [@user.login] do
      visit '/'
      click_on 'Tickets'
      click_on 'Created at'
      uri = URI.parse(current_url)
      assert_equal '/tickets', uri.path
      assert_equal 'sort_order=created_at_desc', uri.query
    end
  end
end

