class ApiIntegrationTest < ActionDispatch::IntegrationTest

  DUMMY_TOKEN = Token.new
  RACK_ENV = {'HTTP_AUTHORIZATION' => %Q(Token token="#{DUMMY_TOKEN.to_s}")}

  def login(user = nil)
    @user ||= user ||= FactoryGirl.create(:user)
    # DUMMY_TOKEN will be frozen. So let's use a dup
    @token ||= DUMMY_TOKEN.dup
    # make sure @token is up to date if it already exists
    @token.reload if @token.persisted?
    @token.user_id = @user.id
    @token.last_seen_at = Time.now
    @token.save
  end

  def assert_login_required
    assert_equal 401, get_response.status
    assert_json_response error: I18n.t(:not_authorized_login)
  end

  teardown do
    if @user && @user.persisted?
      Identity.destroy_all_for @user
      @user.reload.destroy
    end
    if @token && @token.persisted?
      @token.reload.destroy
    end
  end
end
