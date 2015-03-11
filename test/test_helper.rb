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

#
# Create databases, since the temporary databases might not have been created
# when `rake couchrest:migrate` was run.
#

Token.create_database! if Token.respond_to?(:create_database)
CouchRest::Session::Document.create_database! if CouchRest::Session::Document.respond_to?(:create_database)
User.create_tmp_database! if User.respond_to?(:create_tmp_database)
