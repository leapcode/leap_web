require 'test_helper'

class CertPoolTest < ActiveSupport::TestCase

  setup do
    2.times { Cert.create! }
  end

  teardown do
    Cert.all.each {|c| c.destroy}
  end

  test "picks random sample" do
    Cert.create! # with 3 certs chances are pretty low we pick the same one 40 times.
    picked = []
    first = Cert.sample.id
    current = Cert.sample.id
    40.times do
      break if current != first
      current = Cert.sample.id
    end
    assert_not_equal current, first
  end

  test "picks cert from the pool" do
    assert_difference "Cert.count", -1 do
      cert = Cert.pick_from_pool
    end
  end

  test "err's out if all certs have been destroyed" do
    sample = Cert.first.tap{|c| c.destroy}
    Cert.all.each {|c| c.destroy}
    assert_raises RECORD_NOT_FOUND do
      Cert.expects(:sample).returns(sample)
      cert = Cert.pick_from_pool
    end
  end

  test "picks other cert if first pick has been destroyed" do
    first = Cert.first.tap{|c| c.destroy}
    second = Cert.first
    Cert.expects(:sample).at_least_once.
      returns(first).
      then.returns(second)
    cert = Cert.pick_from_pool
    assert_equal second, cert
    assert_nil Cert.first
  end

end
