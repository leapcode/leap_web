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
    if @subject.public_key.present?
      Base64.encode64(@subject.public_key.to_s)
    end
  end

  def links
    links = {}
    links[:public_key] = { type: 'PGP', href: key } if key
    return links
  end

  def to_json(options)
    {
      subject: "acct:#{email_identifier}",
      aliases: [ user_url(@subject, :host => @request.host) ],
      links:   links
    }.to_json(options)
  end

end
