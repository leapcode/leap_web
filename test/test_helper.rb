ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'mocha'

# Load support files from all engines
Dir["#{File.dirname(__FILE__)}/../*/test/support/**/*.rb"].each { |f| require f }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end
