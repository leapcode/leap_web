class RackTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include Warden::Test::Helpers
  include LeapWebCore::AssertResponses

  def app
    OUTER_APP
  end
end
