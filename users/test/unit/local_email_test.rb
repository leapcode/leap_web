require 'test_helper'

class LocalEmailTest < ActiveSupport::TestCase

  test "appends domain" do
    local = LocalEmail.new(handle)
    assert_equal LocalEmail.new(email), local
  end

  test "returns handle" do
    local = LocalEmail.new(email)
    assert_equal handle, local.handle
  end

  test "prints full email" do
    local = LocalEmail.new(handle)
    assert_equal email, "#{local}"
  end

  def handle
    "asdf"
  end

  def email
    "asdf@" + APP_CONFIG[:domain]
  end
end
