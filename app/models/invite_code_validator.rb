class InviteCodeValidator < ActiveModel::Validator
  def validate(user)

    user_invite_code = InviteCode.find_by_invite_code user.invite_code

    if not_existent?(user_invite_code.invite_code)
      add_error_to_user("This is not a valid code", user)

    elsif count_greater_than_zero?(user_invite_code.invite_count)
      add_error_to_user("This code has already been used", user)

    else
      user_invite_code.invite_count += 1
      user_invite_code.save
    end
  end

  private
  def not_existent?(code)
    InviteCode.find_by_invite_code(code) == nil
  end

  def count_greater_than_zero?(code)
    code > 0
  end

  def add_error_to_user(error, user)
    user.errors[:invite_code] << error
  end
end


