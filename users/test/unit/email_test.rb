require 'test_helper'

class EmailAliasTest < ActiveSupport::TestCase

  setup do
    @attribs = User.valid_attributes_hash
    User.find_by_login(@attribs[:login]).try(:destroy)
    @user = User.new(@attribs)
  end

  test "email aliases need to be unique" do
    # TODO build helper for this ... make_record(User)
    email_alias = "valid_alias@domain.net"
    attribs = User.valid_attributes_hash.merge(:login => "other_user")
    User.find_by_login(attribs[:login]).try(:destroy)
    other_user = User.new(attribs)
    other_user.attributes = {:email_aliases => [email_alias]}
    other_user.save
    @user.attributes = {:email_aliases => [email_alias]}
    assert !@user.valid?
    # TODO handle errors
  end

  test "email aliases may not conflict with emails" do
    # TODO build helper for this ... make_record(User)
    email_alias = "valid_alias@domain.net"
    attribs = User.valid_attributes_hash.merge(:login => "other_user", :email => email_alias)
    User.find_by_login(attribs[:login]).try(:destroy)
    other_user = User.new(attribs)
    @user.attributes = {:email_aliases => [email_alias]}
    assert !@user.valid?
  end
end
