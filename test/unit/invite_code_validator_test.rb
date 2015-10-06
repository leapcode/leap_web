require 'test_helper'

class InviteCodeValidatorTest < ActiveSupport::TestCase
  test "user should not be created with invalid invite code" do
    with_config invite_required: true do
    invalid_user = FactoryGirl.build(:user)

    assert !invalid_user.valid?
    end
  end

  test "user should be created with valid invite code" do
    valid_user = FactoryGirl.build(:user)
    valid_code = InviteCode.create
    valid_user.invite_code = valid_code.invite_code

    assert valid_user.valid?
  end

  test "trying to create a user with invalid invite code should add error" do
    with_config invite_required: true do
    invalid_user = FactoryGirl.build(:user, :invite_code => "a non-existent code")

    invalid_user.valid?

    errors = {invite_code: ["This is not a valid code"]}
    assert_equal errors, invalid_user.errors.messages
    end
  end


  test "Invite count >= invite max uses is not accepted for new account signup" do
    validator = InviteCodeValidator.new nil

    user_code = InviteCode.new
    user_code.invite_count = 1
    user_code.save

    user = FactoryGirl.build :user
    user.invite_code = user_code.invite_code

    validator.validate(user)

    assert_equal ["This code has already been used"], user.errors[:invite_code]

  end

  test "Invite count < invite max uses is accepted for new account signup" do
    validator = InviteCodeValidator.new nil

    user_code = InviteCode.create
    user_code.save

    user = FactoryGirl.build :user
    user.invite_code = user_code.invite_code

    validator.validate(user)

    assert_equal [], user.errors[:invite_code]
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