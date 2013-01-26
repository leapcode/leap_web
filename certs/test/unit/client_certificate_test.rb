require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  setup do
    @sample = ClientCertificate.new
  end

  test "new cert has all we need" do
    assert @sample.key
    assert @sample.cert
  end

end
