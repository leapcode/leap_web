Given /the provider config is:$/ do |config|
  @tempfile = Tempfile.new('provider.json')
  @tempfile.write config
  @tempfile.close
  StaticConfigController::PROVIDER_JSON = @tempfile.path
end

# use with @config tag so the config changes are reverted after the scenario
Given /^"([^"]*)" is (enabled|disabled|"[^"]") in the config$/ do |key, value|
  value = case value
          when 'disabled' then false
          when 'enabled' then true
          else value.gsub('"', '')
          end
  APP_CONFIG.merge! key => value
end
