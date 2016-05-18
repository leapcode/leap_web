require 'test_helper'

class Api::CertsControllerTest < ApiControllerTest

  test "create unlimited cert without login" do
    with_config allow_anonymous_certs: true do
      cert = expect_cert('UNLIMITED')
      api_post :create
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

  test "create limited cert" do
    with_config allow_limited_certs: true do
      login
      cert = expect_cert('LIMITED')
      api_post :create
      assert_response :success
      assert_equal cert.to_s, @response.body
    end
  end

  test "fail to create cert when disabled" do
    login :enabled? => false
    api_post :create
    assert_access_denied
  end

  test "create unlimited cert" do
    login effective_service_level: ServiceLevel.new(id: 2)
    cert = expect_cert('UNLIMITED')
    api_post :create
    assert_response :success
    assert_equal cert.to_s, @response.body
  end

  test "GET still works as an alias" do
    login effective_service_level: ServiceLevel.new(id: 2)
    cert = expect_cert('UNLIMITED')
    api_get :show
    assert_response :success
    assert_equal cert.to_s, @response.body
  end

  test "redirect if no eip service offered" do
    api_post :create
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
