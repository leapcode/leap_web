require_relative 'test_helper'

class RotationTest < MiniTest::Test

  class Token < CouchRest::Model::Base
    include CouchRest::Model::Rotation
    property :token, String
    rotate_database 'test_rotate', :every => 1.day
  end

  TEST_DB_RE = /test_rotate_\d+/

  def test_rotate
    delete_all_dbs
    doc = nil
    original_name = nil
    next_db_name = nil

    Time.stub :now, Time.gm(2015,3,7,0) do
      Token.create_database!
      doc = Token.create!(:token => 'aaaa')
      original_name = Token.rotated_database_name
      assert database_exists?(original_name)
      assert_equal 1, count_dbs
    end

    # do nothing yet
    Time.stub :now, Time.gm(2015,3,7,22) do
      Token.rotate_database_now(:window => 1.hour)
      assert_equal original_name, Token.rotated_database_name
      assert_equal 1, count_dbs
    end

    # create next db, but don't switch yet.
    Time.stub :now, Time.gm(2015,3,7,23) do
      Token.rotate_database_now(:window => 1.hour)
      assert_equal 2, count_dbs
      next_db_name = Token.rotated_database_name(Time.gm(2015,3,8))
      assert original_name != next_db_name
      assert database_exists?(next_db_name)
      sleep 0.2 # allow time for documents to replicate
      assert_equal(
        Token.get(doc.id).token,
        Token.get(doc.id, database(next_db_name)).token
      )
    end

    # use next db
    Time.stub :now, Time.gm(2015,3,8) do
      Token.rotate_database_now(:window => 1.hour)
      assert_equal 2, count_dbs
      assert_equal next_db_name, Token.rotated_database_name
      token = Token.get(doc.id)
      token.update_attributes(:token => 'bbbb')
      assert_equal 'bbbb', Token.get(doc.id).token
      assert_equal 'aaaa', Token.get(doc.id, database(original_name)).token
    end

    # delete prior db
    Time.stub :now, Time.gm(2015,3,8,1) do
      Token.rotate_database_now(:window => 1.hour)
      assert_equal 1, count_dbs
    end
  end

  private

  def database(db_name)
    Token.server.database(Token.db_name_with_prefix(db_name))
  end

  def database_exists?(dbname)
    Token.database_exists?(dbname)
  end

  def delete_all_dbs(regexp=TEST_DB_RE)
    Token.server.databases.each do |db|
      if regexp.match(db)
        Token.server.database(db).delete!
      end
    end
  end

  def count_dbs(regexp=TEST_DB_RE)
    Token.server.databases.grep(regexp).count
  end

end
