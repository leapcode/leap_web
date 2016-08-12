#
# For users with login '*test_user*', we don't want to store these documents in
# the main users db. This is because we create and destroy a lot of test
# users. This weirdness of using a different db for some users breaks a lot of
# things, such as associations. However, this is OK for now since we don't need
# those for running the frequent nagios tests.
#
# This module is included in user.rb. This will only work if it is included
# after designs are defined, otherwise, the design definition will overwrite
# find_by_login().
#

module TemporaryUser
  extend ActiveSupport::Concern

  USER_DB = 'users'
  TMP_USER_DB = 'tmp_users'
  TMP_LOGIN   = 'tmp_user'  # created and deleted frequently
  TEST_LOGIN  = 'test_user' # created, rarely deleted

  included do
    # since the original find_by_login is dynamically created with
    # instance_eval, it appears that we also need to use instance eval to
    # override it.
    instance_eval <<-EOS, __FILE__, __LINE__ + 1
      def find_by_login(*args)
        if args.grep(/^#{TMP_LOGIN}/).any?
          by_login.database(tmp_database).key(*args).first()
        else
          by_login.key(*args).first()
        end
      end
    EOS
  end

  module ClassMethods
    def get(id, db = database)
      super(id, db) || super(id, tmp_database)
    end
    alias :find :get

    def database
      @database ||= prepare_database USER_DB
    end

    def tmp_database
      @tmp_database ||= prepare_database TMP_USER_DB
    end


    # create the tmp db if it doesn't exist.
    # requires admin access.
    def create_tmp_database!
      design_doc.sync!(tmp_database.tap{|db|db.create!})
    end

    def is_tmp?(login)
      !login.nil? && login =~ /^#{TMP_LOGIN}/
    end

    def is_test?(login)
      !login.nil? && (login =~ /^#{TMP_LOGIN}/ || login =~ /^#{TEST_LOGIN}/)
    end
  end

  def database
    if login.present? && login.include?(TMP_LOGIN)
      self.class.tmp_database
    else
      self.class.database
    end
  end

  # returns true if this User instance is stored in tmp db.
  def is_tmp?
    self.class.is_tmp?(self.login)
  end

  # returns true if this user is used for testing purposes
  # (either a temporary or long lived)
  def is_test?
    self.class.is_test?(self.login)
  end

end
