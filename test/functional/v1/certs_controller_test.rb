require 'test_helper'

class V1::CertsControllerTest < ActionController::TestCase

  test "send limited cert without login" do
    with_config allow_limited_certs: true, allow_anonymous_certs: true do
      cert = stub :to_s => "limited cert"
      ClientCertificate.expects(:new).with(:prefix => APP_CONFIG[:limited_cert_prefix]).returns(cert)
      get :show
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

  test "send unlimited cert" do
    with_config allow_unlimited_certs: true do
      login
      cert = stub :to_s => "unlimited cert"
      ClientCertificate.expects(:new).with(:prefix => APP_CONFIG[:unlimited_cert_prefix]).returns(cert)
      get :show
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

  test "login required if anonymous certs disabled" do
    with_config allow_anonymous_certs: false do
      get :show
      assert_response :redirect
    end
  end

  test "send limited cert" do
    with_config allow_limited_certs: true, allow_unlimited_certs: false do
      login
      cert = stub :to_s => "real cert"
      ClientCertificate.expects(:new).with(:prefix => APP_CONFIG[:limited_cert_prefix]).returns(cert)
      get :show
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

end
