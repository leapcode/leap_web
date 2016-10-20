# use with @tempfile, @config
Given /there is a config for the (.*)$/ do |config|
  @dummy_config = {dummy_config_for: config}.to_json
  @tempfile = Tempfile.new("#{config}.json")
  @tempfile.write @dummy_config
  @tempfile.close
  @orig_config ||= APP_CONFIG.dup
  config = "#{config}-service" unless config == 'provider'
  APP_CONFIG[:config_file_paths].merge! config => @tempfile.path
end

# use with @config
Given /^"([^"]*)" is (enabled|disabled|"[^"]") in the config$/ do |key, value|
  @orig_config ||= APP_CONFIG.dup
  value = case value
          when 'disabled' then false
          when 'enabled' then true
          else value.gsub('"', '')
          end
  APP_CONFIG.merge! key => value
end

Then /^the response should be that config$/ do
  assert_equal @dummy_config, last_response.body
end
