#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

RAKE=true   # let environment initialization code know if we are running via rake or not.

require 'rake/packagetask'
require 'rubygems/package_task'

spec = eval(File.read('leap_web.gemspec'))
Gem::PackageTask.new(spec) do |p|
    p.gem_spec = spec
end

require File.expand_path('../config/application', __FILE__)

LeapWeb::Application.load_tasks
