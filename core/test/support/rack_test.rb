class RackTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include Warden::Test::Helpers
  include LeapWebCore::AssertResponses

  CONFIG_RU = (Rails.root + 'config.ru').to_s
  OUTER_APP = Rack::Builder.parse_file(CONFIG_RU).first

  def app
    OUTER_APP
  end

end
