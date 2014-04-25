require 'test_helper'

class AnonymousUserTest < ActiveSupport::TestCase

  setup do
    @anonymous = AnonymousUser.new
  end

  test "has nil values" do
    assert_nil @anonymous.id
    assert_nil @anonymous.email_address
    assert_nil @anonymous.login
  end

  test "has no messages" do
    assert_equal [], @anonymous.messages
  end

  test "has anonymous service level" do
    assert @anonymous.effective_service_level.is_a? AnonymousServiceLevel
  end

end
