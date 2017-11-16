module Api
  class UsersController < ApiController
    include ControllerExtension::FetchUser

    # allow optional access to this controller using API auth tokens:
    before_filter :token_authenticate

    before_filter :fetch_user, :only => [:update, :destroy]
    before_filter :require_monitor, :only => [:index, :show]
    before_filter :require_login, :only => [:index, :update, :destroy]

    respond_to :json

    # used for autocomplete for admins in the web ui
    def index
      if params[:query]
        @users = User.login_starts_with(params[:query])
        respond_with @users.map(&:login).sort
      else
        render :json => {'error' => 'query required', 'status' => :unprocessable_entity}
      end
    end

    def show
      if params[:login]
        @user = User.find_by_login(params[:login])
      elsif params[:id]
        @user = User.find(params[:id])
      end
      if @user
        respond_with user_response
      else
        not_found
      end
    end

    def create
      if current_user.is_monitor?
        create_test_account
      elsif APP_CONFIG[:allow_registration]
        create_account
      else
        head :forbidden
      end
    end

    def update
      if user_update_params.present?
        @user.account.update user_update_params
        respond_with @user
      else
        # TODO: move into identity controller
        key = update_pgp_key(user_key_param[:public_key])
        respond_with key
      end
    end

    def destroy
      @user.account.destroy(release_handles)
      if @user == current_user
        logout
      end
      render :json => {'success' => 'user deleted'}
    end

    private

    def user_response
      @user.to_hash.tap do |user_hash|
        if @user == current_user
          user_hash['is_admin'] = @user.is_admin?
        end
      end
    end

    def user_update_params
      params.require(:user).permit :login,
        :password_verifier,
        :password_salt,
        :recovery_code_verifier,
        :recovery_code_salt
    end

    def user_key_param
      params.require(:user).permit :public_key
    end

    def release_handles
      current_user.is_monitor? || params[:identities] == "destroy"
    end

    # tester auth can only create test users.
    def create_test_account
      if User::is_test?(params[:user][:login])
        @user = Account.create(params[:user], :invite_required => false)
        respond_with @user
      else
        head :forbidden
      end
    end

    def create_account
      if APP_CONFIG[:allow_registration]
        @user = Account.create(params[:user])
        respond_with @user # return ID instead?
      else
        head :forbidden
      end
    end

    def update_pgp_key(key)
      PgpKey.new(key).tap do |key|
        if key.valid?
          identity = Identity.for(@user)
          identity.set_key(:pgp, key)
          identity.save
        end
      end
    end
  end
end
