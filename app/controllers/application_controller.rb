class ApplicationController < ActionController::Base
  protect_from_forgery

  ActiveSupport.run_load_hooks(:application_controller, self)

  def not_found
    raise RECORD_NOT_FOUND.new('Not Found')
  end
end
