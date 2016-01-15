class InviteCodesController < ApplicationController

  respond_to :html
  before_filter :require_login
  before_filter :require_admin
  before_filter :fetch_invite, only: :destroy

  def index
    @invite  = InviteCode.new # for the creation form.
    @invites = InviteCode.all.page(params[:page]).per(APP_CONFIG[:pagination_size])
    respond_with @invites
  end

  def create
    @invite = InviteCode.new(params[:invite_code])
    @invite.save # throws exception on error (!)
    flash[:success] = t('created') + " #{@invite.invite_code}"
  rescue
    flash[:error] = "could not save invite code" # who knows why, invite.errors is empty
  ensure
    redirect_to invite_codes_path
  end

  def destroy
    @invite.destroy
    redirect_to invite_codes_path
  end

  protected

  def fetch_invite
    @invite = InviteCode.find(params[:id])
  end

end
