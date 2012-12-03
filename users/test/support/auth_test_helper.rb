module AuthTestHelper
  include StubRecordHelper
  extend ActiveSupport::Concern

  # Controller will fetch current user from warden.
  # Make it pick up our current_user
  included do
    setup do
      request.env['warden'] ||= stub :user => nil
    end
  end

  def login(user_or_method_hash = {})
    @current_user = stub_record(User, user_or_method_hash)
    unless @current_user.respond_to? :is_admin?
      @current_user.stubs(:is_admin?).returns(false)
    end
    request.env['warden'] = stub :user => @current_user
    return @current_user
  end

  def assert_access_denied(denied = true)
    if denied
      assert_equal({:alert => "Not authorized"}, flash.to_hash)
      assert_redirected_to login_path
    else
      assert flash[:alert].blank?
    end
  end

end

class ActionController::TestCase
  include AuthTestHelper
end
