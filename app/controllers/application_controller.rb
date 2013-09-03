class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :no_cache_header
  before_filter :no_frame_header

  ActiveSupport.run_load_hooks(:application_controller, self)

  protected


  rescue_from StandardError do |e|
    respond_to do |format|
      format.json { render_json_error }
      format.all  { raise e }  # reraise the exception so the normal thing happens.
    end
  end

  def render_json_error
    render status: 500,
      json: {error: "The server failed to process your request. We'll look into it."}
  end

  #
  # Allows us to pass through bold text to flash messages. See format_flash() for where this is reversed.
  #
  # TODO: move to core
  #
  def bold(str)
    "[b]#{str}[/b]"
  end
  helper_method :bold

  #
  # we want to prevent the browser from caching anything, just to be safe.
  #
  def no_cache_header
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end

  #
  # prevent app from being embedded in an iframe, for browsers that support x-frame-options.
  #
  def no_frame_header
    response.headers["X-Frame-Options"] = "DENY"
  end

end
