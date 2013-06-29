class ApplicationController < ActionController::Base
  protect_from_forgery

  ActiveSupport.run_load_hooks(:application_controller, self)

  protected

  #
  # Allows us to pass through bold text to flash messages. See format_flash() for where this is reversed.
  #
  # TODO: move to core
  #
  def bold(str)
    "[b]#{str}[/b]"
  end
  helper_method :bold

end
