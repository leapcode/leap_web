require 'test_helper'

class EmailAliasTest < ActiveSupport::TestCase

  setup do
    @attribs = User.valid_attributes_hash
    User.find_by_login(@attribs[:login]).try(:destroy)
    @user = User.new(@attribs)
  end

  test "no email aliases set in the beginning" do
    assert_equal [], @user.email_aliases
  end

  test "adding email alias" do
    email_alias = "valid_alias@domain.net"
    @user.add_email_alias(email_alias)
    assert_equal [email_alias], @user.email_aliases
  end

  test "email aliases need to be unique" do
    # todo build helper for this ... make_record(User)
    email_alias = "valid_alias@domain.net"
    attribs = User.valid_attributes_hash.merge(:login => "other_user")
    User.find_by_login(attribs[:login]).try(:destroy)
    other_user = User.new(attribs)
    other_user.add_email_alias(email_alias)
    @user.add_email_alias(email_alias)
    # todo: how do we handle errors? Should email_alias become an ActiveModel?
    assert_equal [], @user.email_aliases
  end

  test "email aliases may not conflict with emails" do
    # todo build helper for this ... make_record(User)
    email_alias = "valid_alias@domain.net"
    attribs = User.valid_attributes_hash.merge(:login => "other_user", :email => email_alias)
    User.find_by_login(attribs[:login]).try(:destroy)
    other_user = User.new(attribs)
    @user.add_email_alias(email_alias)
    # todo: how do we handle errors? Should email_alias become an ActiveModel?
    assert_equal [], @user.email_aliases
  end

  test "can retrieve user by email alias" do
    email_alias = "valid_alias@domain.net"
    @user.add_email_alias(email_alias)
    assert_equal @user, User.find_by_email_alias(email_alias)
    assert_equal @user, User.find_by_email(email_alias)
  end
end
