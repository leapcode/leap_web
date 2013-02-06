require 'test_helper'

class UserTest < ActiveSupport::TestCase

  include SRP::Util
  setup do
    @user = FactoryGirl.build(:user)
  end

  test "test set of attributes should be valid" do
    @user.valid?
    assert_equal Hash.new, @user.errors.messages
  end

  test "test require hex for password_verifier" do
    @user.password_verifier = "QWER"
    assert !@user.valid?
  end

  test "test require alphanumerical for login" do
    @user.login = "qw#r"
    assert !@user.valid?
  end

  test "find_by_param gets User by id" do
    @user.save
    assert_equal @user, User.find_by_param(@user.id)
    @user.destroy
  end

  test "to_param gives user id" do
    assert_equal @user.id, @user.to_param
  end

  test "verifier returns number for the hex in password_verifier" do
    assert_equal @user.password_verifier.hex, @user.verifier
  end

  test "salt returns number for the hex in password_salt" do
    assert_equal @user.password_salt.hex, @user.salt
  end

  test 'normal user is no admin' do
    assert !@user.is_admin?
  end

  test 'user with login in APP_CONFIG is an admin' do
    admin_login = APP_CONFIG['admins'].first
    @user.login = admin_login
    assert @user.is_admin?
  end

  test "login needs to be unique" do
    other_user = FactoryGirl.create :user, login: @user.login
    assert !@user.valid?
    other_user.destroy
  end

  test "login needs to be different from other peoples email aliases" do
    other_user = FactoryGirl.create :user
    other_user.email_aliases.build :email => @user.login
    other_user.save
    assert !@user.valid?
    other_user.destroy
  end

end
