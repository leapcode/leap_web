# RackTest assumes all requests to be local.
# Braintree requests need to go out to a different server though.
# So we use a middleware to catch these and send them out again.

class BraintreeTestApp
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    config = Braintree::Configuration.instantiate
    if request.path =~ /\/merchants\/#{config.merchant_id}\/transparent_redirect_requests$/
      #proxy post to braintree
      uri = URI.parse(config.protocol + "://" + config.server + ":" +
        config.port.to_s + request.path)
      http = Net::HTTP.new(uri.host, uri.port)
      res = http.post(uri.path, request.body.read)

      if res.code == "303"
        header_hash = res.header.to_hash
        header_hash["location"].first.gsub!("http://localhost:3000/", "http://www.example.com/")
        [303, {"location" => header_hash["location"].first}, ""]
      else
        raise "unexpected response from Braintree: expected a 303"
      end
    else
      @app.call(env)
    end
  end

  def request
    @request = Rack::Request.new(@env)
  end
end

