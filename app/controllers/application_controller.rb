class ApplicationController < ActionController::Base
  protect_from_forgery

  ActiveSupport.run_load_hooks(:application_controller, self)

end
