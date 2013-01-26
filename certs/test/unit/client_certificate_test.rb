require 'test_helper'

class ClientCertificateTest < ActiveSupport::TestCase

  setup do
    @sample = ClientCertificate.new ClientCertificate.valid_attributes_hash
  end

  test "stub cert for testing is valid" do
    assert @sample.valid?
  end

  test "setting random on create validation" do
    @sample.random = "asdf"
    assert @sample.valid?
    assert @sample.random.is_a? Float
    assert @sample.random >= 0
    assert @sample.random < 1
  end

  test "validates random" do
    @sample.save # make sure we are past the on_create
    assert @sample.valid?
    ["asdf", 1, 2, -0.1, nil, "asdf"].each do |invalid|
      @sample.random = invalid
      assert !@sample.valid?, "#{invalid} should not be a valid value for random"
    end
  end

  test "validates key" do
    @sample.key = nil
    assert !@sample.valid?, "Cert should require key"
  end

  test "validates cert" do
    @sample.cert = nil
    assert !@sample.valid?, "Cert should require cert"
  end
end
