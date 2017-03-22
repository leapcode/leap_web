# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

unless APP_CONFIG[:secret_key_base] or APP_CONFIG[:secret_token]
  raise StandardError.new("No secret_key_base or secret_token defined in config/config.yml - please provide one.")
end

if APP_CONFIG[:secret_key_base]
  LeapWeb::Application.config.secret_key_base = APP_CONFIG[:secret_key_base]
end

if APP_CONFIG[:secret_token]
  LeapWeb::Application.config.secret_token = APP_CONFIG[:secret_token]
end
