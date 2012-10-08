require File.expand_path('../../../lib/leap_web/version', __FILE__)

namespace :gem do

  engines = %w(core users certs help)

  desc "run rake gem for all gems"
  task :build do
    engines.each do |gem_name|
      puts "########################### #{gem_name} #########################"
      cmd = "rm -rf #{gem_name}/pkg"; puts cmd; system cmd
      cmd = "cd #{gem_name} && bundle exec rake gem"; puts cmd; system cmd
    end
    cmd = "rm -rf pkg"; puts cmd; system cmd
    cmd = "bundle exec rake gem"; puts cmd; system cmd
  end
  
  desc "run gem install for all gems"
  task :install do

    engines.each do |gem_name|
      puts "########################### #{gem_name} #########################"
      cmd = "rm -rf #{gem_name}/pkg"; puts cmd; system cmd
      cmd = "cd #{gem_name} && bundle exec rake gem"; puts cmd; system cmd
      cmd = "cd #{gem_name}/pkg && gem install leap_web_#{gem_name}-#{LeapWeb::VERSION}.gem"; puts cmd; system cmd
    end
    cmd = "rm -rf pkg"; puts cmd; system cmd
    cmd = "bundle exec rake gem"; puts cmd; system cmd
    cmd = "gem install pkg/leap_web-#{LeapWeb::VERSION}.gem"; puts cmd; system cmd
  end

  desc "Release all gems to gemcutter. Package leap web components, then push"
  task :release do

    engines.each do |gem_name|
      puts "########################### #{gem_name} #########################"
      cmd = "cd #{gem_name}/pkg && gem push leap_web_#{gem_name}-#{LeapWeb::VERSION}.gem"; puts cmd; system cmd
    end
    cmd = "gem push pkg/leap_web-#{LeapWeb::VERSION}.gem"; puts cmd; system cmd
  end
end
