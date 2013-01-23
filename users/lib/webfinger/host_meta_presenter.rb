require 'uri'

class Webfinger::HostMetaPresenter
  def initialize(request)
    @request = request
  end

  def to_json(options = {})
    {
      subject: subject,
      links: links
    }.to_json(options)
  end

  def subject
    url = URI.parse(@request.url)
    url.path = ''
    url.to_s
  end

  def links
    { lrdd: { type: 'application/xrd+xml', template: webfinger_template } }
  end

  protected

  def webfinger_template(path = 'webfinger', query_param='q')
    "#{subject}/#{path}?#{query_param}={uri}"
  end
end
