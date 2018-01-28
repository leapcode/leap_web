if defined?(Rack)

  # Monkey patch Rack::MockResponse to work properly with response debugging
  class Rack::MockResponse
    def to_str
      body
    end
  end

  World(Rack::Test::Methods)

end

Given /^I set headers:$/ do |headers|
  headers.rows_hash.each do |key,value|
    replace = value.dup
    replace.sub!('MY_AUTH_TOKEN', @my_auth_token.to_s) if @my_auth_token
    header key, replace
  end
end

Given /^I send and accept (XML|JSON)$/ do |type|
  header 'Accept', "application/#{type.downcase}"
  header 'Content-Type', "application/#{type.downcase}"
end

Given /^I send and accept HTML$/ do
  header 'Accept', "text/html"
  header 'Content-Type', "application/x-www-form-urlencoded"
end

When /^I authenticate as the user "([^"]*)" with the password "([^"]*)"$/ do |user, pass|
  authorize user, pass
end

When /^I digest\-authenticate as the user "(.*?)" with the password "(.*?)"$/ do |user, pass|
  digest_authorize user, pass
end

When /^I (?:have sent|send) a (GET|POST|PUT|DELETE|PATCH) request (?:for|to) "([^"]*)"(?: with the following:)?$/ do |*args|
  request_type = args.shift
  path = args.shift
  input = args.shift

  request_opts = {method: request_type.downcase.to_sym}

  unless input.nil?
    if input.class == Cucumber::MultilineArgument::DataTable
      request_opts[:params] = input.rows_hash
    else
      request_opts[:input] = input
    end
  end
  request path, request_opts
end

Then /^show me the (unparsed)?\s?response$/ do |unparsed|
  if unparsed == 'unparsed'
    puts last_response.body
  elsif last_response.headers['Content-Type'] =~ /json/
    json_response = JSON.parse(last_response.body)
    puts JSON.pretty_generate(json_response)
  else
    puts last_response.headers
    puts last_response.body
  end
end

Then /^the response status should be "([^"]*)"$/ do |status|
  if self.respond_to? :should
    last_response.status.should == status.to_i
  else
    assert_equal status.to_i, last_response.status
  end
end

Then /^the response should (not)?\s?have "([^"]*)"$/ do |negative, key|
  json    = JSON.parse(last_response.body)
  if self.respond_to?(:should)
    if negative.present?
      json[key].should be_blank
    else
      json[key].should be_present
    end
  else
    if negative.present?
      assert json[key].blank?
    else
      assert json[key].present?
    end
  end
end


Then /^the response should (not)?\s?have "([^"]*)" with(?: the text)? "([^"]*)"$/ do |negative, key, text|
  json    = JSON.parse(last_response.body)
  if self.respond_to?(:should)
    if negative.present?
      json[key].should_not == text
    else
      results.should == text
    end
  else
    if negative.present?
      assert ! json[key] == text
    else
      assert_equal text, json[key]
    end
  end
end

Then /^the response should be:$/ do |json|
  expected = JSON.parse(json)
  actual = JSON.parse(last_response.body)

  if self.respond_to?(:should)
    actual.should == expected
  else
    assert_equal expected, actual
  end
end

Then /^the response should have "([^"]*)" with a length of (\d+)$/ do |json_path, length|
  json = JSON.parse(last_response.body)
  results = JsonPath.new(json_path).on(json)
  if self.respond_to?(:should)
    results.length.should == length.to_i
  else
    assert_equal length.to_i, results.length
  end
end
