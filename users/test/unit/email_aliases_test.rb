require 'test_helper'

class EmailAliasTest < ActiveSupport::TestCase

  setup do
    @attribs = User.valid_attributes_hash
    User.find_by_login(@attribs[:login]).try(:destroy)
    @user = User.new(@attribs)
    @attribs.merge!(:login => "other_user")
    User.find_by_login(@attribs[:login]).try(:destroy)
    @other_user = User.create(@attribs)
    @alias = "valid_alias@#{APP_CONFIG[:domain]}"
    User.find_by_email_or_alias(@alias).try(:destroy)
  end

  test "no email aliases set in the beginning" do
    assert_equal [], @user.email_aliases
  end

  test "adding email alias through params" do
    @user.attributes = {:email_aliases_attributes => {"0" => {:email => @alias}}}
    assert @user.changed?
    assert @user.save
    assert_equal @alias, @user.email_aliases.first.to_s
  end

  test "adding email alias directly" do
    @user.email_aliases.build :email => @alias
    assert @user.save
    assert_equal @alias, @user.reload.email_aliases.first.to_s
  end

  test "duplicated email aliases are invalid" do
    @user.email_aliases.build :email => @alias
    @user.save
    assert_invalid_alias @alias
  end

  test "email alias needs to be different from other peoples email" do
    @other_user.email = @alias
    @other_user.save
    assert_invalid_alias @alias
  end

  test "email needs to be different from other peoples email aliases" do
    @other_user.email_aliases.build :email => @alias
    @other_user.save
    assert_invalid_alias @alias
  end

  test "email is invalid as email alias" do
    @user.email = @alias
    assert_invalid_alias @alias
  end

  test "find user by email alias" do
    @user.email_aliases.build :email => @alias
    assert @user.save
    assert_equal @user, User.find_by_email_or_alias(@alias)
    assert_equal @user, User.find_by_email_alias(@alias)
    assert_nil User.find_by_email(@alias)
  end

  def assert_invalid_alias(string)
    email_alias = @user.email_aliases.build :email => string
    assert !email_alias.valid?
    assert !@user.valid?
  end

end
