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
    @current_user = stub_record(:user, user_or_method_hash, true)
    request.env['warden'] = stub :user => @current_user
    return @current_user
  end

  def assert_access_denied(denied = true, logged_in = true)
    if denied
      assert_equal({:alert => "Not authorized"}, flash.to_hash)
      # todo: eventually probably eliminate separate conditions
      assert_redirected_to login_path if !logged_in
      assert_redirected_to root_path if logged_in
    else
      assert flash[:alert].blank?
    end
  end

end

class ActionController::TestCase
  include AuthTestHelper
end
