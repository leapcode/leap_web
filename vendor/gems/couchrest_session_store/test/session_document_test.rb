require_relative 'test_helper'

class SessionDocumentTest < MiniTest::Test

  def test_storing_session
    sid = '1234'
    session = {'a' => 'b'}
    options = {}
    couchrest_session = CouchRest::Session.build_or_update(sid, session, options)
    couchrest_session.save
    couchrest_session.fetch(sid)
    assert_equal session, couchrest_session.to_session
  end

  def test_storing_session_with_conflict
    sid = '1234'
    session = {'a' => 'b'}
    options = {}
    cr_session = CouchRest::Session.build_or_update(sid, session, options)
    cr_session2 = CouchRest::Session.build_or_update(sid, session, options)
    cr_session.save
    cr_session2.save
    cr_session2.fetch(sid)
    assert_equal session, cr_session2.to_session
  end

end
