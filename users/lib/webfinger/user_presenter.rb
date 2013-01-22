class Webfinger::UserPresenter
  include Rails.application.routes.url_helpers
  attr_accessor :subject

  def initialize(subject, request)
    @subject = subject
    @request = request
  end

  def email_identifier
    "#{@subject.username}@#{@request.host}"
  end

  def key
    Base64.encode64(@subject.public_key.to_s)
  end

  def to_json(options)
    {
      subject: "acct:#{email_identifier}",
      aliases: [ user_url(@subject, :host => @request.host) ],
      links:   {
        public_key:  { type: 'PGP', href: key }
      }
    }.to_json(options)
  end

end
