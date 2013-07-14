source "http://rubygems.org"

group :test do
  # moching and stubing
  gem 'mocha', '~> 0.13.0', :require => false
  # integration testing
  gem 'capybara'
  # headless js integration testing
  gem 'poltergeist'
  # required for save_and_open_page in integration tests
  # gem 'launchy'
end

group :test, :development do
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'thin'
  gem 'quiet_assets'
end

