class InviteCodeValidator < ActiveModel::Validator
  def validate(user)

    user_invite_code = InviteCode.find_by_invite_code user.invite_code

    if not_existent?(user.invite_code)
      add_error_to_user("This is not a valid code", user)

    elsif count_greater_than_zero?(user_invite_code.invite_count)
      add_error_to_user("This code has already been used", user)
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


