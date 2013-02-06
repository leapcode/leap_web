require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  setup do
    @sample = ClientCertificate.new
  end

  test "new cert has all we need" do
    assert @sample.key
    assert @sample.cert
  end

  test "cert issuer matches ca subject" do
    cert = OpenSSL::X509::Certificate.new(@sample.cert)
    assert_equal ClientCertificate.root_ca.openssl_body.subject, cert.issuer
  end

end
