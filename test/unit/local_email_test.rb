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

  test "blacklists rfc2142" do
    black_listed = LocalEmail.new('hostmaster')
    assert !black_listed.valid?
  end

  test "blacklists etc passwd" do
    black_listed = LocalEmail.new('nobody')
    assert !black_listed.valid?
  end

  test "whitelist overwrites automatic blacklists" do
    with_config handle_whitelist: ['nobody', 'hostmaster'] do
      white_listed = LocalEmail.new('nobody')
      assert white_listed.valid?
      white_listed = LocalEmail.new('hostmaster')
      assert white_listed.valid?
    end
  end

  test "blacklists from config" do
    black_listed = LocalEmail.new('www-data')
    assert !black_listed.valid?
  end

  test "blacklist from config overwrites whitelist" do
    with_config handle_whitelist: ['www-data'] do
      black_listed = LocalEmail.new('www-data')
      assert !black_listed.valid?
    end
  end

  def handle
    @handle ||= Faker::Internet.user_name
  end

  def email
    handle + "@" + APP_CONFIG[:domain]
  end
end
