require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  test "new cert has all we need" do
    sample = ClientCertificate.new
    assert sample.key
    assert sample.cert
    assert sample.to_s
  end

  test "free cert has configured postfix" do
    sample = ClientCertificate.new(free: true)
    postfix = APP_CONFIG[:free_cert_postfix]
    assert sample.cert.subject.common_name.include?(postfix)
  end

  test "real cert has no free cert postfix" do
    sample = ClientCertificate.new
    postfix = APP_CONFIG[:free_cert_postfix]
    assert !sample.cert.subject.common_name.include?(postfix)
  end

  test "cert issuer matches ca subject" do
    sample = ClientCertificate.new
    cert = OpenSSL::X509::Certificate.new(sample.cert.to_pem)
    assert_equal ClientCertificate.root_ca.openssl_body.subject, cert.issuer
  end

end
