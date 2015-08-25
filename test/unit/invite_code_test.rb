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

  test "the invite code count gets set to 0 upon creation" do
     code1 = InviteCode.new
     code1.save
     assert_equal code1.invite_count, 0
  end

   # TODO: does the count go up when code gets entered?
   test "Invite code count goes up by 1 when the invite code is entered" do

     validator = InviteCodeValidator.new nil

     user = FactoryGirl.build :user
     user_code = InviteCode.new
     user_code.save
     user.invite_code = user_code.invite_code


     validator.validate(user)

     user_code.reload
     assert_equal 1, user_code.invite_count

   end
#
#
#   # TODO: count >0 is not accepted for signup
   # test "Invite count >0 is not accepted for new account signup" do

  #  end

end

