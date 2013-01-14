require 'test_helper'

class EmailTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.build :user
    @other_user = FactoryGirl.build :user
    @email_string = "valid_alias@#{APP_CONFIG[:domain]}"
    User.find_by_email_or_alias(@email_string).try(:destroy)
  end

  teardown do
    @user.destroy if @user.persisted? # just in case
    @other_user.destroy if @other_user.persisted?
  end

  test "email needs to be different from other peoples email" do
    @other_user.email = @email_string
    @other_user.save
    assert_invalid_email @email_string
  end

  test "email needs to be different from other peoples email aliases" do
    @other_user.email_aliases.build :email => @email_string
    @other_user.save
    assert_invalid_email @email_string
  end

  test "email needs to be different from email aliases" do
    @user.email_aliases.build :email => @email_string
    @user.save
    assert_invalid_email @email_string
  end

  test "non local emails are invalid" do
    assert_invalid_email "not_valid@mail.me"
  end

  test "local emails are valid" do
    local_email = "valid@#{APP_CONFIG[:domain]}"
    @user.email = local_email
    @user.valid?
    assert_equal Hash.new, @user.errors.messages
  end

  test "find user by email" do
    email = "finding@test.me"
    @user.email = email
    @user.save
    assert_equal @user, User.find_by_email(email)
    assert_equal @user, User.find_by_email_or_alias(email)
    assert_nil User.find_by_email_alias(email)
  end

  def assert_invalid_email(string)
    @user.email = string
    assert !@user.valid?
    assert @user.errors.keys.include?(:email)
  end

end
