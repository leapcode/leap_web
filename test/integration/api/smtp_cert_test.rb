require 'test_helper'
require 'openssl'

class SmtpCertTest < ApiIntegrationTest

  test "retrieve smtp cert" do
    @user = FactoryGirl.create :user, effective_service_level_code: 2
    login
    get '/1/smtp_cert', {}, RACK_ENV
    assert_text_response
    assert_response_includes "BEGIN RSA PRIVATE KEY"
    assert_response_includes "END RSA PRIVATE KEY"
    assert_response_includes "BEGIN CERTIFICATE"
    assert_response_includes "END CERTIFICATE"
  end

  test "key matches the cert" do
    @user = FactoryGirl.create :user, effective_service_level_code: 2
    login
    get '/1/smtp_cert', {}, RACK_ENV
    assert_text_response
    cert = OpenSSL::X509::Certificate.new(get_response.body)
    key = OpenSSL::PKey::RSA.new(get_response.body)
    assert cert.check_private_key(key)
  end

  # we'll store the fingerprint later.
  test "fingerprint matches" do
    @user = FactoryGirl.create :user, effective_service_level_code: 2
    login
    get '/1/smtp_cert', {}, RACK_ENV
    assert_text_response
    cert = OpenSSL::X509::Certificate.new(get_response.body)
    fingerprint = OpenSSL::Digest::SHA1.hexdigest(cert.to_der).scan(/../).join(':')
    skip "we're not storing the fingerprints yet"
    assert_equal fingerprint, @user.identity.cert_fingerprints.last
  end

  test "fetching smtp certs requires email account" do
    login
    get '/1/smtp_cert', {}, RACK_ENV
    assert_json_response error: I18n.t(:not_authorized)
  end

  test "no anonymous smtp certs" do
    with_config allow_anonymous_certs: true do
      get '/1/smtp_cert', {}, RACK_ENV
      assert_json_response error: I18n.t(:not_authorized)
    end
  end
end
