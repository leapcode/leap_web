require 'test_helper'

class CertsControllerTest < ActionController::TestCase
  setup do
  end

  test "should send free cert without login" do
    cert = stub :cert => "free cert", :key => "key"
    ClientCertificate.expects(:new).with(free: true).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.key + cert.cert, @response.body
  end

  test "should send cert" do
    login
    cert = stub :cert => "adsf", :key => "key"
    ClientCertificate.expects(:new).with(free: false).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.key + cert.cert, @response.body
  end
end
