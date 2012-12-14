require 'test_helper'

class CertTest < ActiveSupport::TestCase

  setup do
    @sample = LeapCA::Cert.new LeapCA::Cert.valid_attributes_hash
  end

  test "stub cert for testing is valid" do
    assert @sample.valid?
  end

  test "validates random" do
    [-1, 1, nil, "asdf"].each do |invalid|
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
