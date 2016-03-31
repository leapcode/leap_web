require_relative '../../test_helper'

class V1::IdentitiesControllerTest < ActionController::TestCase

  test "api monitor can fetch identity" do
    monitor_auth do
      identity = FactoryGirl.create :identity
      get :show, :id => identity.address, :format => 'json'
      assert_response :success
      assert_equal identity, assigns(:identity)

      get :show, :id => "blahblahblah", :format => 'json'
      assert_response :not_found
    end
  end


  test "anonymous cannot fetch identity" do
    identity = FactoryGirl.create :identity
    get :show, :id => identity.address, :format => 'json'
    assert_response :forbidden
  end

end
