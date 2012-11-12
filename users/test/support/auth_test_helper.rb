module AuthTestHelper

  def stub_logged_in
    @user_id = stub
    @user = stub
    session[:user_id] = @user_id
    User.expects(:find).once.with(@user_id).returns(@user)
    return @user
  end

  def stub_logged_out
    #todo: this seems wrong.
    @user_id = stub
    session[:user_id] = @user_id
    User.expects(:find).once.with(@user_id).returns(nil)
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
