require_relative 'test_helper'

#
# This doesn't really test much, but is useful if you want to see what happens
# when you have a lot of documents.
#

class StressTest < MiniTest::Test

  COUNT = 200 # change to 200,000 if you dare

  class Stress < CouchRest::Model::Base
    include CouchRest::Model::Rotation
    property :token, String
    property :expires_at, Time
    rotate_database 'stress_test', :every => 1.day, :expiration_field => :expires_at
  end

  def test_stress
    delete_all_dbs /^couchrest_stress_test_\d+$/

    Stress.database!
    COUNT.times do |i|
      doc = Stress.create!(:token => SecureRandom.hex(32), :expires_at => expires(i))
    end

    Time.stub :now, 1.day.from_now do
      Stress.rotate_database_now(:window => 1.hour)
      sleep 0.5
      assert_equal (COUNT/100)+1, Stress.database.info["doc_count"]
    end
  end

  private

  def delete_all_dbs(regexp=TEST_DB_RE)
    Stress.server.databases.each do |db|
      if regexp.match(db)
        Stress.server.database(db).delete!
      end
    end
  end

  def expires(i)
    if i % 100 == 0
      1.hour.from_now.utc
    else
      1.hour.ago.utc
    end
  end
end
