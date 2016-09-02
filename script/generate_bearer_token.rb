require "net/http"
require "uri"
require "json"
require "base64"
require "optparse"

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Create your bearer_token for twitter by including following [options]:"

  opts.on("--key KEY", "consumer_key of your twitter application") do |key|
    options[:conkey] = key
  end

  opts.on("--secret SECRET", "consumer_secret of your twitter application") do |secret|
    options[:consec] = secret
  end

  opts.on("--file FILE", "file where the bearer_token should be stored to (e.g. config/secrets.yml)") do |file|
    options[:file] = file
  end

end

option_parser.parse!

if options[:conkey].nil? || options[:consec].nil? then
  puts option_parser
  exit
else
  consumer_key = options[:conkey]
  consumer_secret = options[:consec]
end

uri = URI("https://api.twitter.com/oauth2/token")
data = "grant_type=client_credentials"
cre   = Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")
authorization_headers = { "Authorization" => "Basic #{cre}"}

Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  response = http.request_post(uri, data, authorization_headers)
  token_hash = JSON.parse(response.body)
  @bearer_token = token_hash["access_token"]
end

if options[:file].nil? then
  puts @bearer_token
else
  if options[:file] == "config/secrets.yml"
    Rails.application.secrets.twitter['bearer_token'] = @bearer_token
  end
end
