require 'test_helper'
require 'openssl'

class SmtpCertTest < ApiIntegrationTest

  setup do
    @testcode = InviteCode.new
    @testcode.save!
  end

  test "retrieve smtp cert" do
    @user = FactoryGirl.create :user, effective_service_level_code: 2, :invite_code => @testcode.invite_code
    login
    post '/1/smtp_cert', {}, RACK_ENV
    assert_text_response
    assert_response_includes "BEGIN RSA PRIVATE KEY"
    assert_response_includes "END RSA PRIVATE KEY"
    assert_response_includes "BEGIN CERTIFICATE"
    assert_response_includes "END CERTIFICATE"
  end

  test "cert and key" do
    @user = FactoryGirl.create :user, effective_service_level_code: 2, :invite_code => @testcode.invite_code
    login
    post '/1/smtp_cert', {}, RACK_ENV
    assert_text_response
    cert = OpenSSL::X509::Certificate.new(get_response.body)
    key = OpenSSL::PKey::RSA.new(get_response.body)
    assert cert.check_private_key(key)
    prefix = "/CN=#{@user.email_address}"
    assert_equal prefix, cert.subject.to_s.slice(0,prefix.size)
  end

  test "fingerprint is stored with identity" do
    @user = FactoryGirl.create :user, effective_service_level_code: 2, :invite_code => @testcode.invite_code
    login
    post '/1/smtp_cert', {}, RACK_ENV
    assert_text_response
    cert = OpenSSL::X509::Certificate.new(get_response.body)
    fingerprint = OpenSSL::Digest::SHA1.hexdigest(cert.to_der).scan(/../).join(':')
    number, unit = APP_CONFIG[:client_cert_lifespan].split(' ')
    expiry = Time.now.utc.at_midnight.advance(unit.to_sym => number.to_i)
    expiry_string = expiry.to_date.to_s
    fingerprints = {fingerprint => expiry_string}
    assert_equal fingerprints, @user.reload.identity.cert_fingerprints
  end

  test "fetching smtp certs requires email account" do

    login
    post '/1/smtp_cert', {}, RACK_ENV
    assert_access_denied
  end

  test "no anonymous smtp certs" do
    with_config allow_anonymous_certs: true do
      post '/1/smtp_cert', {}, RACK_ENV
      assert_login_required
    end
  end
end
