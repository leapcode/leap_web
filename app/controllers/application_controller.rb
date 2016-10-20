class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :no_cache_header
  before_filter :no_frame_header
  before_filter :language_header

  # UPGRADE: this won't be needed in Rails 5 anymore as it's the default
  # behavior if a template is present but a different format would be
  # rendered and that template is not present
  before_filter :verify_request_format!, if: :mime_types_specified

  rescue_from StandardError, :with => :default_error_handler
  rescue_from CouchRest::Exception, :with => :default_error_handler

  ActiveSupport.run_load_hooks(:application_controller, self)

  protected

  def mime_types_specified
    mimes = collect_mimes_from_class_level
    mimes.present?
  end

  def default_error_handler(exc)
    respond_to do |format|
      format.json { render_json_error(exc) }
      format.all  { raise exc }  # reraise the exception so the normal thing happens.
    end
  end

  #
  # I think this should be 'errors', not 'error', since that is what
  # `respond_with @object` will return. For now, I am leaving this as 'error',
  # since there is some code that depends on this.
  #
  def render_json_error(e)
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    if e.is_a?(CouchRest::StorageMissing)
      render status: 500, json: {error: "The database '#{e.db}' does not exist!"}
    else
      render status: 500, json: {error: "The server failed to process your request. We'll look into it (#{e.class})."}
    end
  end

  ##
  ## LOCALE
  ##

  #
  # Before filter to set the current locale. Possible outcomes:
  #
  #   (a) do nothing for certain routes and requests.
  #   (b) if path already starts with locale, set I18n.locale and default_url_options.
  #   (c) otherwise, redirect so that path starts with locale.
  #
  def set_locale
    if request_may_have_locale?(request)
      if CommonLanguages::available_code?(params[:locale])
        I18n.locale = params[:locale]
      else
        I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
        if I18n.locale != I18n.default_locale
          redirect_to url_for(params.merge(:locale => I18n.locale))
        end
      end
    end
  end

  def default_url_options(options={})
    if request_may_have_locale?(request) && I18n.locale != I18n.default_locale
      { :locale => I18n.locale }
    else
      { :locale => nil }
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

  private

  #
  # URL paths for which we don't enforce the locale as the prefix of the path.
  #
  NON_LOCALE_PATHS = /^\/(assets|webfinger|.well-known|rails|key|[0-9]+)($|\/)/

  #
  # For some requests, we ignore locale determination.
  #
  def request_may_have_locale?(request)
    request.path !~ NON_LOCALE_PATHS
  end
end
