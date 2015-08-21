require 'test_helper'

class InviteCodeTest < ActiveSupport::TestCase

  test "it is created with an invite code" do
    code = InviteCode.new
    assert_not_nil code.invite_code
  end

  test "the invite code can be read from couch db correctly" do
    code1 = InviteCode.new
    code1.save

    code2 = InviteCode.find_by__id code1.id

    assert_equal code1.invite_code, code2.invite_code

  end


end