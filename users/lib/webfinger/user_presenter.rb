class Webfinger::UserPresenter
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
end
