class ApiIntegrationTest < ActionDispatch::IntegrationTest

  DUMMY_TOKEN = Token.new
  RACK_ENV = {'HTTP_AUTHORIZATION' => %Q(Token token="#{DUMMY_TOKEN.to_s}")}

  def login(user = nil)
    @user ||= user ||= FactoryGirl.create(:user)
    @token ||= DUMMY_TOKEN
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
