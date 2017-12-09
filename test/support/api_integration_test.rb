class ApiIntegrationTest < ActionDispatch::IntegrationTest

  DUMMY_TOKEN = Token.new
  RACK_ENV = {'HTTP_AUTHORIZATION' => %Q(Token token="#{DUMMY_TOKEN.to_s}")}

  def api_version
    2
  end

  def login(user = nil)
    @user ||= user ||= create_invited_user
    # DUMMY_TOKEN will be frozen. So let's use a dup
    @token ||= DUMMY_TOKEN.dup
    # make sure @token is up to date if it already exists
    @token.reload if @token.persisted?
    @token.user_id = @user.id
    @token.last_seen_at = Time.now
    @token.save
  end

  def create_invited_user(options = {})
    @testcode = InviteCode.new
    @testcode.save!
    options.reverse_merge! invite_code: @testcode.invite_code
    FactoryBot.create :user, options
  end

  teardown do
    if @user && @user.persisted?
      @user.destroy_identities
      @user.reload.destroy
    end
    if @token && @token.persisted?
      @token.reload.destroy
    end
  end
end
