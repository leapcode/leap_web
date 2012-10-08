require File.expand_path('../task_helper', __FILE__)
include TaskHelper


namespace :gem do

  desc "run rake gem for all gems"
  task :build => :clear do
    each_gem do |gem_name|
      putsys "cd #{gem_name} && bundle exec rake gem"
    end
    putsys "bundle exec rake gem"
  end
  
  desc "run rake gem for all gems"
  task :clear do
    each_gem do |gem_name|
      putsys "rm -rf #{gem_name}/pkg"
    end
    putsys "rm -rf pkg"
  end
  
  desc "run gem install for all gems"
  task :install => :build do

    each_gem do |gem_name|
      putsys "cd #{gem_name}/pkg && gem install leap_web_#{gem_name}-#{LeapWeb::VERSION}.gem"
    end
    putsys "gem install pkg/leap_web-#{LeapWeb::VERSION}.gem"
  end

  desc "Release all gems to gemcutter. Package leap web components, then push"
  task :release do

    each_gem do |gem_name|
      putsys "cd #{gem_name}/pkg && gem push leap_web_#{gem_name}-#{LeapWeb::VERSION}.gem"
    end
    putsys "gem push pkg/leap_web-#{LeapWeb::VERSION}.gem"
  end
end
