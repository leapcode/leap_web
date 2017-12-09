require_relative '../../test_helper'

class Api::IdentitiesControllerTest < ApiControllerTest

  test "api monitor can fetch identity" do
    monitor_auth do
      identity = create_identity
      api_get :show, :id => identity.address, :format => 'json'
      assert_response :success
      assert_equal identity, assigns(:identity)

      api_get :show, :id => "blahblahblah", :format => 'json'
      assert_response :not_found
    end
  end


  test "anonymous cannot fetch identity" do
    identity = create_identity
    api_get :show, :id => identity.address, :format => 'json'
    assert_response :forbidden
  end

  def create_identity
    FactoryBot.create :identity
  end
end
