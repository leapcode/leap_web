class IdentitiesController < ApplicationController

  respond_to :html, :json
  before_filter :require_login
  before_filter :require_admin
  before_filter :fetch_identity, only: :destroy
  before_filter :protect_main_email, only: :destroy

  def index
    if params[:query].present?
      @identities = Identity.address_starts_with(params[:query]).limit(100)
    else
      @identities = []
    end
    respond_with @identities.map(&:login).sort
  end

  def destroy
    @identity.destroy
    redirect_to identities_path
  end

  protected
  def fetch_identity
    @identity = Identity.find(params[:id])
  end

  def protect_main_email
    if @identity.status == :main_email
      flash[:error] = "You cannot destroy the main email. Remove or Rename the user instead."
      redirect_to identities_path
    end
  end
end
