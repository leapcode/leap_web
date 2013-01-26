require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  setup do
    @sample = ClientCertificate.new ClientCertificate.valid_attributes_hash
  end

  test "stub cert for testing is valid" do
    assert @sample.valid?
  end

  test "validates key" do
    @sample.key = nil
    assert @sample.valid?
    assert @sample.key, "Cert should generate key"
  end

  test "validates cert" do
    @sample.cert = nil
    assert @sample.valid?
    assert @sample.cert, "Cert should generate cert"
  end
end
