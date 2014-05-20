ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'mocha/setup'

# Load support files from toplevel
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load support files from all engines
Dir["#{File.dirname(__FILE__)}/../engines/*/test/support/**/*.rb"].each { |f| require f }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  protected

  def logfile_path
    Rails.root + 'tmp' + "#{self.class.name.underscore}.#{__name__}.log"
  end

  def screenshot_path
    Rails.root + 'tmp' + "#{self.class.name.underscore}.#{__name__}.png"
  end

  def file_path(name)
    File.join(Rails.root, 'test', 'files', name)
  end

  require 'i18n/missing_translations'
  at_exit { I18n.missing_translations.dump }
end
