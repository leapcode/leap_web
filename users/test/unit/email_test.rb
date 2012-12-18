require 'test_helper'

class EmailTest < ActiveSupport::TestCase

  setup do
    # TODO build helper for this ... make_record(User)
    @attribs = User.valid_attributes_hash
    User.find_by_login(@attribs[:login]).try(:destroy)
    @user = User.new(@attribs)
    @attribs.merge!(:login => "other_user")
    User.find_by_login(@attribs[:login]).try(:destroy)
    @other_user = User.create(@attribs)
  end

  teardown do
    @user.destroy if @user.persisted? # just in case
    @other_user.destroy
  end


  test "email aliases need to be unique" do
    email_alias = "valid_alias@domain.net"
    @other_user.email_aliases.build :email => email_alias
    @other_user.save
    @user.email_aliases.build :email => email_alias
    assert @user.changed?
    assert !@user.save
    # TODO handle errors
  end

  test "email aliases may not conflict with emails" do
    email_alias = "valid_alias@domain.net"
    @other_user.email = email_alias
    @other_user.save
    @user.email_aliases.build :email => email_alias
    assert @user.changed?
    assert !@user.save
  end
end
