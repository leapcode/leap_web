require 'test_helper'

class TmpUserTest < ActiveSupport::TestCase

  setup do
    InviteCodeValidator.any_instance.stubs(:not_existent?).returns(false)
  end

  test "test_user saved to tmp_users" do
    begin
      assert User.ancestors.include?(TemporaryUser)

      assert_difference('User.database.info["doc_count"]') do
        normal_user = User.create!(:login => 'a'+SecureRandom.hex(5).downcase,
          :password_verifier => 'ABCDEF0010101', :password_salt => 'ABCDEF')
        refute normal_user.database.to_s.include?('tmp')
      end

      assert_difference('User.tmp_database.info["doc_count"]') do
        tmp_user = User.create!(:login => 'test_user_'+SecureRandom.hex(5).downcase,
          :password_verifier => 'ABCDEF0010101', :password_salt => 'ABCDEF')
        assert tmp_user.database.to_s.include?('tmp')
      end
    ensure
      begin
        normal_user.destroy
        tmp_user.destroy
      rescue
      end
    end
  end

end
