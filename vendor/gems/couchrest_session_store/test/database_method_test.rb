require_relative 'test_helper'

class DatabaseMethodTest < MiniTest::Test

  class TestModel < CouchRest::Model::Base
    include CouchRest::Model::DatabaseMethod

    use_database_method :db_name
    property :dbname, String
    property :confirm, String

    def db_name
      "test_db_#{self[:dbname]}"
    end
  end

  def test_instance_method
    doc1 = TestModel.new({:dbname => 'one'})
    doc1.database.create!
    assert doc1.database.root.ends_with?('test_db_one')
    assert doc1.save
    doc1.update_attributes(:confirm => 'yep')

    doc2 = TestModel.new({:dbname => 'two'})
    doc2.database.create!
    assert doc2.database.root.ends_with?('test_db_two')
    assert doc2.save
    doc2.confirm = 'sure'
    doc2.save!

    doc1_copy = CouchRest.get([doc1.database.root, doc1.id].join('/'))
    assert_equal "yep", doc1_copy["confirm"]

    doc2_copy = CouchRest.get([doc2.database.root, doc2.id].join('/'))
    assert_equal "sure", doc2_copy["confirm"]

    doc1.database.delete!
    doc2.database.delete!
  end

  def test_switch_db
    doc_red = TestModel.new({:dbname => 'red', :confirm => 'rose'})
    doc_red.database.create!
    root = doc_red.database.root

    doc_blue = doc_red.clone
    doc_blue.dbname = 'blue'
    doc_blue.database!
    doc_blue.save!

    doc_blue_copy = CouchRest.get([root.sub('red','blue'), doc_blue.id].join('/'))
    assert_equal "rose", doc_blue_copy["confirm"]

    doc_red.database.delete!
    doc_blue.database.delete!
  end

  #
  # A test scenario for database_method in which some user accounts
  # are stored in a seperate temporary database (so that the test
  # accounts don't bloat the normal database).
  #

  class User < CouchRest::Model::Base
    include CouchRest::Model::DatabaseMethod

    use_database_method :db_name
    property :login, String
    before_save :create_db

    class << self
      def get(id, db = database)
        result = super(id, db)
        if result.nil?
          return super(id, choose_database('test-user'))
        else
          return result
        end
      end
      alias :find :get
    end

    protected

    def self.db_name(login = nil)
      if !login.nil? && login =~ /test-user/
        'tmp_users'
      else
        'users'
      end
    end

    def db_name
      self.class.db_name(self.login)
    end

    def create_db
      unless database_exists?(db_name)
        self.database!
      end
    end

  end

  def test_tmp_user_db
    user1 = User.new({:login => 'test-user-1'})
    assert user1.save
    assert User.find(user1.id), 'should find user in tmp_users'
    assert_equal user1.login, User.find(user1.id).login
    assert_equal 'test-user-1', User.server.database('couchrest_tmp_users').get(user1.id)['login']
    assert_raises CouchRest::NotFound do
      User.server.database('couchrest_users').get(user1.id)
    end
  end

end
