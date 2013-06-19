gem "haml", "~> 3.1.7"
gem "bootstrap-sass", "~> 2.1.0"
gem "jquery-rails"
gem "simple_form"
gem 'client_side_validations'
gem 'client_side_validations-simple_form'

gem 'kaminari', "0.13.0" # for pagination. trying 0.13.0 as there seem to be
                         # issues with 0.14.0 when using couchrest

# gem 'bootstrap-editable-rails', "~>0.0.4"

gem 'rails-i18n'  # locale files for built-in validation messages and times
                  # https://github.com/svenfuchs/rails-i18n
                  # for a list of keys:
                  # https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/en.yml
group :assets do
  gem "haml-rails", "~> 0.3.4"
  gem "sass-rails", "~> 3.2.5"
  gem "coffee-rails", "~> 3.2.2"
  gem "uglifier", "~> 1.2.7"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', "~> 0.10.2", :platforms => :ruby

end

