module AuthTestHelper
  extend ActiveSupport::Concern

  # Controller will fetch current user from warden.
  # Make it pick up our current_user
  included do
    setup do
      request.env['warden'] ||= stub :user => nil
    end
  end

  def login(user_or_method_hash = {})
    if user_or_method_hash.respond_to?(:reverse_merge)
      user_or_method_hash.reverse_merge! :is_admin? => false
    end
    @current_user = stub_record(:user, user_or_method_hash)
    request.env['warden'] = stub :user => @current_user
    request.env['HTTP_AUTHORIZATION'] = header_for_token_auth
    return @current_user
  end

  def assert_access_granted
    assert flash[:alert].blank?,
      "expected to have access but there was a flash alert"
  end

  def expect_logout
    expect_warden_logout
    @token.expects(:destroy) if @token
  end

  # authenticate as the api monitor
  def monitor_auth(&block)
    token_auth(APP_CONFIG['api_tokens']['monitor'], &block)
  end

  # authenticate with a token
  def token_auth(token_str)
    original = request.env['HTTP_AUTHORIZATION']
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token_str)
    if block_given?
      yield
      request.env['HTTP_AUTHORIZATION'] = original
    end
  end

  protected

  def header_for_token_auth
    @token = stub_record(:token, :authenticate => @current_user)
    Token.stubs(:find_by_token).with(@token.token).returns(@token)
    ActionController::HttpAuthentication::Token.encode_credentials @token.token
  end

  def expect_warden_logout
    raw = mock('raw session')
    raw.expects(:inspect)
    request.env['warden'].expects(:raw_session).returns(raw)
    request.env['warden'].expects(:logout)
  end

end

class ActionController::TestCase
  include AuthTestHelper
end
