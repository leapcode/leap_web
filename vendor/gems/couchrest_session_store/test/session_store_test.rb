require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SessionStoreTest < MiniTest::Test

  def test_session_initialization
    sid, session = store.send :get_session, env, nil
    assert sid
    assert_equal Hash.new, session
  end

  def test_normal_session_flow
    sid, session = never_expiring_session
    assert_equal [sid, session], store.send(:get_session, env, sid)
    store.send :destroy_session, env, sid, {}
  end

  def test_updating_session
    sid, session = never_expiring_session
    session[:bla] = "blub"
    store.send :set_session, env, sid, session, {}
    assert_equal [sid, session], store.send(:get_session, env, sid)
    store.send :destroy_session, env, sid, {}
  end

  def test_prevent_access_to_design_docs
    sid = '_design/bla'
    session = {views: 'my hacked view'}
    assert_raises CouchRest::NotFound do
      store_session(sid, session)
    end
  end

  def test_unmarshalled_session_flow
    sid, session = init_session
    store_session sid, session, :marshal_data => false
    new_sid, new_session = store.send(:get_session, env, sid)
    assert_equal sid, new_sid
    assert_equal session[:key], new_session["key"]
    store.send :destroy_session, env, sid, {}
  end

  def test_unmarshalled_data
    sid, session = init_session
    store_session sid, session, :marshal_data => false
    couch = CouchTester.new
    data = couch.get(sid)["data"]
    assert_equal session[:key], data["key"]
  end

  def test_logout_in_between
    sid, session = never_expiring_session
    store.send :destroy_session, env, sid, {}
    other_sid, other_session = store.send(:get_session, env, sid)
    assert_equal Hash.new, other_session
  end

  def test_can_logout_twice
    sid, session = never_expiring_session
    store.send :destroy_session, env, sid, {}
    store.send :destroy_session, env, sid, {}
    other_sid, other_session = store.send(:get_session, env, sid)
    assert_equal Hash.new, other_session
  end

  def test_stored_and_not_expired_yet
    sid, session = expiring_session
    doc = CouchRest::Session::Document.fetch(sid)
    expires = doc.send :expires
    assert expires
    assert !doc.expired?
    assert (expires - Time.now) > 0, "Exiry should be in the future"
    assert (expires - Time.now) <= 300, "Should expire after 300 seconds - not more"
    assert_equal [sid, session], store.send(:get_session, env, sid)
  end

  def test_stored_but_expired
    sid, session = expired_session
    other_sid, other_session = store.send(:get_session, env, sid)
    assert_equal Hash.new, other_session, "session should have expired"
    assert other_sid != sid
  end

  def test_find_expired_sessions
    expired, expiring, never_expiring = seed_sessions
    expired_session_ids = store.expired.map {|row| row['id']}
    assert expired_session_ids.include?(expired)
    assert !expired_session_ids.include?(expiring)
    assert !expired_session_ids.include?(never_expiring)
  end

  def test_find_never_expiring_sessions
    expired, expiring, never_expiring = seed_sessions
    never_expiring_session_ids = store.never_expiring.map {|row| row['id']}
    assert never_expiring_session_ids.include?(never_expiring)
    assert !never_expiring_session_ids.include?(expiring)
    assert !never_expiring_session_ids.include?(expired)
  end

  def test_cleanup_expired_sessions
    sid, session = expired_session
    store.cleanup(store.expired)
    assert_raises CouchRest::NotFound do
      CouchTester.new.get(sid)
    end
  end

  def test_keep_fresh_during_cleanup
    sid, session = expiring_session
    store.cleanup(store.expired)
    assert_equal [sid, session], store.send(:get_session, env, sid)
  end

  def test_store_without_expiry
    sid, session = never_expiring_session
    couch = CouchTester.new
    assert_nil couch.get(sid)["expires"]
    assert_equal [sid, session], store.send(:get_session, env, sid)
  end

  def app
    nil
  end

  def store(options = {})
    @store ||= CouchRest::Session::Store.new(app, options)
  end

  def env(settings = {})
    env ||= settings
  end

  # returns the session ids of an expired, and expiring and a never
  # expiring session
  def seed_sessions
    [expired_session, expiring_session, never_expiring_session].map(&:first)
  end

  def never_expiring_session
    store_session *init_session
  end

  def expiring_session
    sid, session = init_session
    store_session(sid, session, expire_after: 300)
  end

  def expired_session
    expire_session *expiring_session
  end

  def init_session
    sid, session = store.send :get_session, env, nil
    session[:key] = "stub"
    return sid, session
  end

  def store_session(sid, session, options = {})
    store.send :set_session, env, sid, session, options
    return sid, session
  end

  def expire_session(sid, session)
    CouchTester.new.update sid,
      "expires" => (Time.now - 10.minutes).utc.iso8601
    return sid, session
  end

end
