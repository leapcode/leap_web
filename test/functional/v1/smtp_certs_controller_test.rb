require 'test_helper'

class V1::SmtpCertsControllerTest < ActionController::TestCase

  test "no smtp cert without login" do
    with_config allow_anonymous_certs: true do
      post :create
      assert_login_required
    end
  end

  test "require service level with email" do
    login
    post :create
    assert_access_denied
  end

  test "send cert with username" do
    login effective_service_level: ServiceLevel.new(id: 2)
    cert = expect_cert(@current_user.email_address)
    cert.expects(:fingerprint).returns('fingerprint')
    post :create
    assert_response :success
    assert_equal cert.to_s, @response.body
  end

  test "fail to create cert when disabled" do
    login :enabled? => false
    post :create
    assert_access_denied
  end

  protected

  def expect_cert(email)
    cert = stub to_s: "#{email.downcase} cert",
      expiry: 1.month.from_now.utc.at_midnight
    ClientCertificate.expects(:new).
      with(:common_name => email).
      returns(cert)
    return cert
  end
end
