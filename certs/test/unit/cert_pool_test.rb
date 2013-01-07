require 'test_helper'

class CertPoolTest < ActiveSupport::TestCase

  setup do
    2.times { LeapCA::Cert.create(LeapCA::Cert.valid_attributes_hash) }
  end

  teardown do
    LeapCA::Cert.all.each {|c| c.destroy}
  end

  test "picks random sample" do
    # with 3 certs chances are pretty low we pick the same one 40 times.
    LeapCA::Cert.create! LeapCA::Cert.valid_attributes_hash
    picked = []
    first = LeapCA::Cert.sample.id
    current = LeapCA::Cert.sample.id
    40.times do
      break if current != first
      current = LeapCA::Cert.sample.id
    end
    assert_not_equal current, first
  end

  test "picks cert from the pool" do
    assert_difference "LeapCA::Cert.count", -1 do
      cert = LeapCA::Cert.pick_from_pool
    end
  end

  test "err's out if all certs have been destroyed" do
    sample = LeapCA::Cert.first.tap{|c| c.destroy}
    LeapCA::Cert.all.each {|c| c.destroy}
    assert_raises RECORD_NOT_FOUND do
      LeapCA::Cert.expects(:sample).returns(sample)
      cert = LeapCA::Cert.pick_from_pool
    end
  end

  test "picks other cert if first pick has been destroyed" do
    first = LeapCA::Cert.first.tap{|c| c.destroy}
    second = LeapCA::Cert.first
    LeapCA::Cert.expects(:sample).at_least_once.
      returns(first).
      then.returns(second)
    cert = LeapCA::Cert.pick_from_pool
    assert_equal second, cert
    assert_nil LeapCA::Cert.first
  end

end
