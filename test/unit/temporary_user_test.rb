require 'test_helper'

class TemporaryUserTest < ActiveSupport::TestCase

  setup do
    InviteCodeValidator.any_instance.stubs(:validate)
  end

  test "TemporaryUser concern is applied" do
    assert User.ancestors.include?(TemporaryUser)
  end

  test "temporary user has tmp_users as db" do
    tmp_user = User.new :login => 'tmp_user_'+SecureRandom.hex(5).downcase
    assert_equal 'leap_web_tmp_users', tmp_user.database.name
  end

  test "normal user has users as db" do
    user = User.new :login => 'a'+SecureRandom.hex(5).downcase
    assert_equal 'leap_web_users', user.database.name
  end

  test "user saved to users" do
    begin
      assert_difference('User.database.info["doc_count"]') do
        normal_user = User.create!(:login => 'a'+SecureRandom.hex(5).downcase,
          :password_verifier => 'ABCDEF0010101', :password_salt => 'ABCDEF')
        refute normal_user.database.to_s.include?('tmp')
      end
    ensure
      begin
        normal_user.destroy
      rescue
      end
    end
  end

  test "tmp_user saved to tmp_users" do
    begin
      assert_difference('User.tmp_database.info["doc_count"]') do
        tmp_user = User.create!(:login => 'tmp_user_'+SecureRandom.hex(5).downcase,
          :password_verifier => 'ABCDEF0010101', :password_salt => 'ABCDEF')
        assert tmp_user.database.to_s.include?('tmp')
      end
    ensure
      begin
        tmp_user.destroy
      rescue
      end
    end
  end

end
