class ApiIntegrationTest < ActionDispatch::IntegrationTest

  DUMMY_TOKEN = Token.new
  RACK_ENV = {'HTTP_AUTHORIZATION' => %Q(Token token="#{DUMMY_TOKEN.to_s}")}

  setup do
    @testcode = InviteCode.new
    @testcode.save!
  end

  def login(user = nil)
    @user ||= user ||= FactoryGirl.create(:user, :invite_code => @testcode.invite_code)
    # DUMMY_TOKEN will be frozen. So let's use a dup
    @token ||= DUMMY_TOKEN.dup
    # make sure @token is up to date if it already exists
    @token.reload if @token.persisted?
    @token.user_id = @user.id
    @token.last_seen_at = Time.now
    @token.save
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
