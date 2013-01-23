class Webfinger::UserPresenter
  include Rails.application.routes.url_helpers
  attr_accessor :user

  def initialize(user, request)
    @user = user
    @request = request
  end

  def to_json(options = {})
    {
      subject: subject,
      aliases: aliases,
      links:   links
    }.to_json(options)
  end

  def subject
    "acct:#{@user.email_address}"
  end

  def aliases
    [ user_url(@user, :host => @request.host) ]
  end

  def links
    links = {}
    links[:public_key] = { type: 'PGP', href: key } if key
    return links
  end

  protected

  def key
    if @user.public_key.present?
      Base64.encode64(@user.public_key.to_s)
    end
  end

end
