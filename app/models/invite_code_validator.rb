class InviteCodeValidator < ActiveModel::Validator

  def validate(user)

    user_invite_code = InviteCode.find_by_invite_code user.invite_code

    if not_existent?(user_invite_code)
      add_error_to_user("This is not a valid code", user)

    elsif has_no_uses_left?(user_invite_code)
      add_error_to_user("This code has already been used", user)
    end
  end

  private
  def not_existent?(code)
    code == nil
  end

  def has_no_uses_left?(code)
    code.invite_count >= code.max_uses
  end

  def add_error_to_user(error, user)
    user.errors[:invite_code] << error
  end
end


