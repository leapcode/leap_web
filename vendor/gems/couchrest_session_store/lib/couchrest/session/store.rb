class CouchRest::Session::Store < ActionDispatch::Session::AbstractStore

  # delegate configure to document
  def self.configure(*args, &block)
    CouchRest::Session::Document.configure *args, &block
  end

  def self.set_options(options)
    @options = options
    if @options[:database]
      CouchRest::Session::Document.use_database @options[:database]
    end
  end

  def initialize(app, options = {})
    super
    self.class.set_options(options)
  end

  def cleanup(rows)
    rows.each do |row|
      doc = CouchRest::Session::Document.fetch(row['id'])
      doc.delete
    end
  end

  def expired
    CouchRest::Session::Document.find_by_expires startkey: 1,
      endkey: Time.now.utc.iso8601
  end

  def never_expiring
    CouchRest::Session::Document.find_by_expires endkey: 1
  end

  private

  def get_session(env, sid)
    if session = fetch_session(sid)
      [sid, session]
    else
      [generate_sid, {}]
    end
  rescue CouchRest::NotFound
    # session data does not exist anymore
    return [sid, {}]
  rescue CouchRest::Unauthorized,
    Errno::EHOSTUNREACH,
    Errno::ECONNREFUSED => e
    # can't connect to couch. We add some status to the session
    # so the app can react. (Display error for example)
    return [sid, {"_status" => {"couch" => "unreachable"}}]
  end

  def set_session(env, sid, session, options)
    raise CouchRest::NotFound if /^_design\/(.*)/ =~ sid
    doc = build_or_update_doc(sid, session, options)
    doc.save
    return sid
  # if we can't store the session we just return false.
  rescue CouchRest::Unauthorized,
    Errno::EHOSTUNREACH,
    Errno::ECONNREFUSED => e
    return false
  end

  def destroy_session(env, sid, options)
    doc = secure_get(sid)
    doc.delete
    generate_sid unless options[:drop]
  rescue CouchRest::NotFound
    # already destroyed - we're done.
    generate_sid unless options[:drop]
  end

  def fetch_session(sid)
    return nil unless sid
    doc = secure_get(sid)
    doc.to_session unless doc.expired?
  end

  def build_or_update_doc(sid, session, options)
    CouchRest::Session::Document.build_or_update(sid, session, options)
  end

  # prevent access to design docs
  # this should be prevented on a couch permission level as well.
  # but better be save than sorry.
  def secure_get(sid)
    raise CouchRest::NotFound if /^_design\/(.*)/ =~ sid
    CouchRest::Session::Document.fetch(sid)
  end

end
