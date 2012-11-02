module AuthTestHelper

  def stub_logged_in
    @user_id = stub
    @user = stub
    session[:user_id] = @user_id
    User.expects(:find).once.with(@user_id).returns(@user)
    return @user
  end

  def stub_logged_out
    @user_id = stub
    session[:user_id] = @user_id
    User.expects(:find).once.with(@user_id).returns(nil)
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
