class Api::KeysController < ApiController

  before_filter :require_login
  before_filter :require_enabled

  # get /keys
  def index
    render json: identity.keys
  end

  def show
    render json: identity.keys[params[:id]]
  end

  def create
    keyring.create type, value
    head :no_content
  rescue Keyring::Error, ActionController::ParameterMissing => e
    render status: 422, json: {error: e.message}
  end

  def update
    keyring.update type, rev: rev, value: value
    head :no_content
  rescue Keyring::NotFound => e
    render status: 404, json: {error: e.message}
  rescue Keyring::Error, ActionController::ParameterMissing => e
    render status: 422, json: {error: e.message}
  end

  def destroy
    keyring.delete type, rev: rev
    head :no_content
  rescue Keyring::NotFound => e
    render status: 404, json: {error: e.message}
  rescue Keyring::Error, ActionController::ParameterMissing => e
    render status: 422, json: {error: e.message}
  end


  protected

  def require_enabled
    if !current_user.enabled?
      access_denied
    end
  end

  def service_level
    current_user.effective_service_level
  end

  def type
    params.require :type
  end

  def value
    params.require :value
  end

  def rev
    params.require :rev
  end

  def keyring
    @keyring ||= Keyring.new identity
  end

  def identity
    @identity ||= Identity.for(current_user)
  end
end
