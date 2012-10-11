require "bundler/capistrano"

set :application, "webapp"

set :scm, :git
set :repository,  "git://leap.se/leap_web"
set :branch, "deploy"

set :deploy_via, :remote_cache
set :deploy_to, '/home/webapp'
set :use_sudo, false

set :normalize_asset_timestamps, false

set :user, "webapp"

set :git_enable_submodules, 1  # we're using an srp js submodule for now

role :web, "94.103.43.3"                          # Your HTTP server, Apache/etc
role :app, "94.103.43.3"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
