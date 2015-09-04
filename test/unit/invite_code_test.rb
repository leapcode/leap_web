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


  test "Invite count >0 is not accepted for new account signup" do
    validator = InviteCodeValidator.new nil

    user_code = InviteCode.new
    user_code.invite_count = 1
    user_code.save

    user = FactoryGirl.build :user
    user.invite_code = user_code.invite_code

    validator.validate(user)

    assert_equal ["This code has already been used"], user.errors[:invite_code]

  end

  test "Invite count 0 is accepted for new account signup" do
    validator = InviteCodeValidator.new nil

    user_code = InviteCode.create

    user = FactoryGirl.build :user
    user.invite_code = user_code.invite_code

    validator.validate(user)

    assert_equal [], user.errors[:invite_code]
  end

  test "There is an error message if the invite code does not exist" do
    validator = InviteCodeValidator.new nil

    user = FactoryGirl.build :user
    user.invite_code = "wrongcode"

    validator.validate(user)

    assert_equal ["This is not a valid code"], user.errors[:invite_code]

  end


end

