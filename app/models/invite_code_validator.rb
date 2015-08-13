class InviteCodeValidator < ActiveModel::Validator
  def validate(user)
    if not_existent?(user.invite_code)
      add_error_to_user("This is not a valid code", user)
    end
  end

  private
  def not_existent?(code)
    InviteCode.find_by_invite_code(code) == nil
  end

  def add_error_to_user(error, user)
    user.errors[:invite_code] << error
  end
end