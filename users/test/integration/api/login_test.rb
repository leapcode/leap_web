require 'test_helper'

CONFIG_RU = (Rails.root + 'config.ru').to_s
OUTER_APP = Rack::Builder.parse_file(CONFIG_RU).first

class AccountFlowTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include Warden::Test::Helpers
  include LeapWebCore::AssertResponses

  def app
    OUTER_APP
  end

  def setup
    @login = "integration_test_user"
  end

  test "require json requests" do
    put "http://api.lvh.me:3000/1/sessions/" + @login,
      :client_auth => "This is not a valid login anyway"
    assert_json_error login: I18n.t(:all_strategies_failed)
  end

end
