require 'couchrest'
require 'couchrest_model'
# ensure compatibility with couchrest_model
gem 'actionpack', '~> 4.0'
require 'action_dispatch'

require 'couchrest/model/database_method'
require 'couchrest/model/rotation'
require 'couchrest/session'
require 'couchrest/session/store'
require 'couchrest/session/document'
