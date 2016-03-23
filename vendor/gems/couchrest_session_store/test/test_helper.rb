require "rubygems"
gem 'minitest'
require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/../lib/couchrest_session_store.rb')
require File.expand_path(File.dirname(__FILE__) + '/couch_tester.rb')
require File.expand_path(File.dirname(__FILE__) + '/test_clock.rb')

# Create the session db if it does not already exist.
CouchRest::Session::Document.create_database!
