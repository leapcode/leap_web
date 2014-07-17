Given /the provider config is:$/ do |config|
  @tempfile = Tempfile.new('provider.json')
  @tempfile.write config
  @tempfile.close
  StaticConfigController::PROVIDER_JSON = @tempfile.path
end
