source "http://rubygems.org"

group :test do
  gem 'mocha', '~> 0.13.0', :require => false
end

group :test, :development do
  gem 'faker'
  gem 'factory_girl_rails'
end

