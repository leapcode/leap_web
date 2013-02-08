source 'https://rubygems.org'

eval(File.read(File.dirname(__FILE__) + '/common_dependencies.rb'))
eval(File.read(File.dirname(__FILE__) + '/ui_dependencies.rb'))

# EITHER fetch all of the leap_web gems in one go
# gem 'leap_web' 
# OR use the local versions for development instead:
gem "leap_web_core", :path => 'core'
gem 'leap_web_users', :path => 'users'
gem 'leap_web_certs', :path => 'certs'
gem 'leap_web_help', :path => 'help'

# To use debugger
gem 'debugger', :platforms => :mri_19
gem 'ruby-debug', :platforms => :mri_18

# unreleased so far ... but leap_web_certs need it

gem 'certificate_authority', :git => 'git://github.com/cchandler/certificate_authority.git'
gem 'couchrest_session_store', :git => 'git://github.com/azul/couchrest_session_store.git'
