require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  test "new cert has all we need" do
    sample = ClientCertificate.new(:common_name => 'test')
    assert sample.key
    assert sample.cert
    assert sample.to_s
  end

  test "cert has configured prefix" do
    prefix = "PREFIX"
    sample = ClientCertificate.new(:prefix => prefix)
    assert sample.cert.subject.common_name.starts_with?(prefix)
  end

  test "cert issuer matches ca subject" do
    sample = ClientCertificate.new(:prefix => 'test')
    cert = OpenSSL::X509::Certificate.new(sample.cert.to_pem)
    assert_equal ClientCertificate.root_ca.openssl_body.subject, cert.issuer
  end

end
