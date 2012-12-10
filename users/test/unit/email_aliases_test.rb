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
    @user.attributes = {:email_aliases_attributes => {"0" => {:email => email_alias}}}
    assert @user.changed?
    assert @user.save
    assert_equal email_alias, @user.email_aliases.first.to_s
  end

  test "can retrieve user by email alias" do
    email_alias = "valid_alias@domain.net"
    @user.attributes = {:email_aliases => [email_alias]}
    @user.save
    assert_equal @user, User.find_by_email_alias(email_alias)
    assert_equal @user, User.find_by_email(email_alias)
  end
end
