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
    cert = stub :cert => "adsf", :key => "key"
    ClientCertificate.expects(:create).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.key + cert.cert, @response.body
  end
end
