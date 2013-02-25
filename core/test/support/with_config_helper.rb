module WithConfigHelper
  extend ActiveSupport::Concern

  def with_config(options)
    old_config = APP_CONFIG.dup
    APP_CONFIG.merge! options
    yield
  ensure
    APP_CONFIG.replace old_config
  end

end

class ActiveSupport::TestCase
  include WithConfigHelper
end
