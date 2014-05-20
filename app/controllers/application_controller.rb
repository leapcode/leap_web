class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :no_cache_header
  before_filter :no_frame_header
  before_filter :language_header

  ActiveSupport.run_load_hooks(:application_controller, self)

  protected

  rescue_from StandardError do |e|
    respond_to do |format|
      format.json { render_json_error(e) }
      format.all  { raise e }  # reraise the exception so the normal thing happens.
    end
  end

  def render_json_error(e)
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    render status: 500,
      json: {error: "The server failed to process your request. We'll look into it."}
  end

  ##
  ## LOCALE
  ##

  #
  # URL paths for which we don't enforce the locale as the prefix of the path.
  #
  NON_LOCALE_PATHS = /^\/(assets|webfinger|.well-known|rails|key|[0-9]+)($|\/)/

  #
  # Before filter to set the current locale. Possible outcomes:
  #
  #   (a) do nothing for certain routes and requests.
  #   (b) if path already starts with locale, set I18n.locale and default_url_options.
  #   (c) otherwise, redirect so that path starts with locale.
  #
  # If the locale happens to be the default local, no paths are prefixed with the locale.
  #
  def set_locale
    if request.method == "GET" && request.format == 'text/html' && request.path !~ NON_LOCALE_PATHS
      if params[:locale] && LOCALES_STRING.include?(params[:locale])
        I18n.locale = params[:locale]
        update_default_url_options
      else
        I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
        update_default_url_options
        if I18n.locale != I18n.default_locale
          redirect_to url_for(params.merge(:locale => I18n.locale))
        end
      end
    else
      update_default_url_options
    end
  end

  def update_default_url_options
    if I18n.locale != I18n.default_locale
      self.default_url_options[:locale] = I18n.locale
    else
      self.default_url_options[:locale] = nil
    end
  end

  ##
  ## HTTP HEADERS
  ## These are in individual helpers so that controllers can disable them if needed.
  ##

  #
  # Not necessary, but kind to let the browser know the current locale.
  #
  def language_header
    response.headers["Content-Language"] = I18n.locale.to_s
  end

  #
  # prevent app from being embedded in an iframe, for browsers that support x-frame-options.
  #
  def no_frame_header
    response.headers["X-Frame-Options"] = "DENY"
  end

  #
  # we want to prevent the browser from caching anything, just to be safe.
  #
  def no_cache_header
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end

end
