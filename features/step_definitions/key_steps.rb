Given /^I have published a "([^"]*)" key$/ do |type|
  identity = Identity.for(@user)
  keyring = Keyring.new(identity)
  SecureRandom.stubs(urlsafe_base64: 'DUMMY_REV')
  keyring.create type, 'DUMMY_KEY'
end

Given /^I have published "([^"]*)" keys$/ do |type|
  identity = Identity.for(@user)
  keyring = Keyring.new(identity)
  SecureRandom.stubs(urlsafe_base64: 'DUMMY_REV')
  keyring.create type, one: 'DUMMY_KEY', two: 'DUMMY_KEY'
end

Then /^I should have published an? "([^"]*)" key(?: with value "([^"]*)")?$/ do |type, value|
  identity = Identity.for(@user)
  keys = identity.keys
  assert_includes keys.keys, type
  assert_equal value, JSON.parse(keys[type])['value'] if value
end

Then /^I should not have published an? "([^"]*)" key$/ do |type|
  identity = Identity.for(@user)
  keys = identity.keys
  refute_includes keys.keys, type
end
