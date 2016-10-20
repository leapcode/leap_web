require 'test_helper'

class UserTest < ActiveSupport::TestCase

  include SRP::Util
  setup do
    InviteCodeValidator.any_instance.stubs(:validate)
    @user = FactoryGirl.build(:user)
  end

  test "don't find a user with login nil" do
    @user.save
    assert_nil User.find_by_login(nil)
  end

  test "design docs in database are authorative" do
    assert !User.design_doc.auto_update,
      "Automatic update of design docs should be disabled"
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

  test "login needs to be unique amongst aliases" do
    other_user = FactoryGirl.create :user
    id = Identity.create_for other_user, address: @user.login
    assert !@user.valid?
    id.destroy
    other_user.destroy
  end

  test "deprecated public key api still works" do
    key = SecureRandom.base64(4096)
    @user.public_key = key
    assert_equal key, @user.public_key
  end

  test "user to hash includes id, login, valid and enabled" do
    hash = @user.to_hash
    assert_equal @user.id, hash[:id]
    assert_equal @user.valid?, hash[:ok]
    assert_equal @user.login, hash[:login]
    assert_equal @user.enabled?, hash[:enabled]
  end


  #
  ## Regression tests
  #
  test "make sure valid does not crash" do
    assert !User.new.valid?
  end

end
