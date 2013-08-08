require 'test_helper'

class LocalEmailTest < ActiveSupport::TestCase

  test "appends domain" do
    local = LocalEmail.new(handle)
    assert_equal LocalEmail.new(email), local
    assert local.valid?
  end

  test "returns handle" do
    local = LocalEmail.new(email)
    assert_equal handle, local.handle
  end

  test "prints full email" do
    local = LocalEmail.new(handle)
    assert_equal email, "#{local}"
  end

  test "validates domain" do
    local = LocalEmail.new(Faker::Internet.email)
    assert !local.valid?
    assert_equal ["needs to end in @#{LocalEmail.domain}"], local.errors[:email]
  end

  def handle
    @handle ||= Faker::Internet.user_name
  end

  def email
    handle + "@" + APP_CONFIG[:domain]
  end
end
