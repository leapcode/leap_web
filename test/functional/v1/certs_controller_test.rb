require 'test_helper'

class V1::CertsControllerTest < ActionController::TestCase

  test "send unlimited cert without login" do
    with_config allow_anonymous_certs: true do
      cert = expect_cert('UNLIMITED')
      get :show
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

  test "send limited cert" do
    with_config allow_limited_certs: true do
      login
      cert = expect_cert('LIMITED')
      get :show
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

  test "send unlimited cert" do
    login effective_service_level: ServiceLevel.new(id: 2)
    cert = expect_cert('UNLIMITED')
    get :show
    assert_response :success
    assert_equal cert.to_s, @response.body
  end

  test "redirect if no eip service offered" do
    get :show
    assert_response :redirect
  end

  protected

  def expect_cert(prefix)
    cert = stub :to_s => "#{prefix.downcase} cert"
    ClientCertificate.expects(:new).
      with(:prefix => prefix).
      returns(cert)
    return cert
  end
end
