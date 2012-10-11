require 'test_helper'

class CertTest < ActiveSupport::TestCase

  setup do
    @sample = Cert.new
    @sample.set_random
    @sample.attach_zip
  end

  test "certs come with attachments" do
    assert @sample.has_attachment? "cert.txt"
  end

  test "cert.zip_attachment returns couchDB attachment" do
    assert_equal "text/plain", @sample.zip_attachment["content_type"]
  end

  test "cert.zipped returns the actual data" do
    @sample.save # This is required !
    assert lines = @sample.zipped.split("\n")
    assert_equal 56, lines.count
    assert_equal "-----BEGIN RSA PRIVATE KEY-----", lines.first.chomp
    assert_equal "-----END CERTIFICATE-----", lines.last.chomp
  end

  test "cert.zipname returns name for the zip file" do
    assert_equal "cert.txt", @sample.zipname
  end

  test "test data is valid" do
    assert @sample.valid?
  end

  test "validates random" do
    @sample.stubs(:set_random)
    [0, 1, nil, "asdf"].each do |invalid|
      @sample.random = invalid
      assert !@sample.valid?, "#{invalid} should not be a valid value for random"
    end
  end

  test "validates attachment" do
    @sample.stubs(:attach_zip)
    @sample.delete_attachment(@sample.zipname)
    assert !@sample.valid?, "Cert should require zipped attachment"
  end

end
