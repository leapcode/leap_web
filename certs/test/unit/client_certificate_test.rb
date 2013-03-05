require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  test "new cert has all we need" do
    sample = ClientCertificate.new
    assert sample.key
    assert sample.cert
    assert sample.to_s
  end

  test "free cert has configured prefix" do
    sample = ClientCertificate.new(free: true)
    prefix = APP_CONFIG[:free_cert_prefix]
    assert sample.cert.subject.common_name.starts_with?(prefix)
  end

  test "real cert has no free cert prefix" do
    sample = ClientCertificate.new
    prefix = APP_CONFIG[:free_cert_prefix]
    assert !sample.cert.subject.common_name.starts_with?(prefix)
  end

  test "cert issuer matches ca subject" do
    sample = ClientCertificate.new
    cert = OpenSSL::X509::Certificate.new(sample.cert.to_pem)
    assert_equal ClientCertificate.root_ca.openssl_body.subject, cert.issuer
  end

end
