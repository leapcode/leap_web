require 'test_helper'

class TravisTest < ActiveSupport::TestCase

  test "can tell we're on travis" do
    skip unless on_travis?
    assert on_travis?
  end

  test "secure variables in travis config" do
    skip unless on_travis?
    assert_equal "secretvalue", ENV["SOMEVAR"]
  end

  test "environment variables in travis config" do
    skip unless on_travis?
    assert_equal "ME", ENV["TST"]
  end

  def on_travis?
    !!ENV["TRAVIS"]
  end
end
