require 'test_helper'

class InviteCodeTest < ActiveSupport::TestCase

  test "it is created with an invite code" do
    code = InviteCode.new
    assert_not_nil code.invite_code
  end

  test "the invite code can be read from couch db correctly" do
    code1 = InviteCode.new
    code1.save
    code2 = InviteCode.find_by_invite_code code1.invite_code
    assert_equal code1.invite_code, code2.invite_code
  end

  test "the invite code count gets set to 0 upon creation" do
     code1 = InviteCode.new
     code1.save
     assert_equal code1.invite_count, 0
  end


end

