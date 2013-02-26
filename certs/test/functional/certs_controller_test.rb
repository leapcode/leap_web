require 'test_helper'

class CertsControllerTest < ActionController::TestCase

  test "send free cert without login" do
    cert = stub :to_s => "free cert"
    ClientCertificate.expects(:new).with(free: true).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.to_s, @response.body
  end

  test "send cert" do
    login
    cert = stub :to_s => "real cert"
    ClientCertificate.expects(:new).with(free: false).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.to_s, @response.body
  end

  test "login required if free certs disabled" do
    with_config free_certs_enabled: false do
      get :show
      assert_response :redirect
    end
  end

  test "get paid cert if free certs disabled" do
    with_config free_certs_enabled: false do
      login
      cert = stub :to_s => "real cert"
      ClientCertificate.expects(:new).with(free: false).returns(cert)
      get :show
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

end
