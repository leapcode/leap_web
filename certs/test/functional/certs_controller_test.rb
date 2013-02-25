require 'test_helper'

class CertsControllerTest < ActionController::TestCase
  setup do
  end

  test "should send free cert without login" do
    cert = stub :to_s => "free cert"
    ClientCertificate.expects(:new).with(free: true).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.to_s, @response.body
  end

  test "should send cert" do
    login
    cert = stub :to_s => "real cert"
    ClientCertificate.expects(:new).with(free: false).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.to_s, @response.body
  end
end
