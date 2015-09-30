require 'test_helper'

class IdentitiesControllerTest < ActionController::TestCase

  setup do
    InviteCodeValidator.any_instance.stubs(:validate)
  end

  test "admin can list active and blocked ids" do
    login :is_admin? => true
    get :index
    assert_response :success
    assert ids = assigns(:identities)
  end

  test "non-admin can't list usernames" do
    login
    get :index
    assert_access_denied
  end

  test "requires login" do
    get :index
    assert_login_required
  end

  test "admin can unblock username" do
    # an identity without user_id and destination is a blocked handle
    identity = FactoryGirl.create :identity
    login :is_admin? => true
    delete :destroy, id: identity.id
    assert_response :redirect
    assert_nil Identity.find(identity.id)
  end

  test "admin cannot remove main identity" do
    user = FactoryGirl.create :user
    identity = FactoryGirl.create :identity,
      Identity.attributes_from_user(user)
    login :is_admin? => true
    delete :destroy, id: identity.id
    assert_response :redirect
    assert_equal identity, Identity.find(identity.id)
  end

end
