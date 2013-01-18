require 'test_helper'

class EmailAliasTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.build :user
    @alias = "valid_alias"
    # make sure no existing records are in the way...
    User.find_by_login_or_alias(@alias).try(:destroy)
  end

  test "no email aliases set in the beginning" do
    assert_equal [], @user.email_aliases
  end

  test "adding email alias through params" do
    @user.attributes = {:email_aliases_attributes => {"0" => {:email => @alias}}}
    assert @user.changed?
    assert @user.save
    assert_equal @alias, @user.email_aliases.first.username
  end

  test "adding email alias directly" do
    @user.email_aliases.build :email => @alias
    assert @user.save
    assert_equal @alias, @user.email_aliases.first.username
  end

  test "duplicated email aliases are invalid" do
    @user.email_aliases.build :email => @alias
    @user.save
    assert_invalid_alias @alias
  end

  test "email alias needs to be different from other peoples login" do
    other_user = FactoryGirl.create :user, :login => @alias
    assert_invalid_alias @alias
    other_user.destroy
  end

  test "email needs to be different from other peoples email aliases" do
    other_user = FactoryGirl.create :user, :email_aliases_attributes => {'1' => @alias}
    assert_invalid_alias @alias
    other_user.destroy
  end

  test "login is invalid as email alias" do
    @user.login = @alias
    assert_invalid_alias @alias
  end

  test "find user by email alias" do
    @user.email_aliases.build :email => @alias
    assert @user.save
    assert_equal @user, User.find_by_login_or_alias(@alias)
    assert_equal @user, User.find_by_alias(@alias)
    assert_nil User.find_by_login(@alias)
  end

  def assert_invalid_alias(string)
    email_alias = @user.email_aliases.build :email => string
    assert !email_alias.valid?
    assert !@user.valid?
  end

end
