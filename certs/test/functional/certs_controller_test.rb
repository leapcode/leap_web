require 'test_helper'

class CertsControllerTest < ActionController::TestCase
  setup do
  end

  test "should require login" do
    get :show
    assert_response :redirect
    assert_redirected_to login_url
  end

  test "should send cert" do
    login
    cert = stub :zipped => "adsf", :zipname => "cert_stub.zip"
    Cert.expects(:pick_from_pool).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.zipped, @response.body
  end
end
