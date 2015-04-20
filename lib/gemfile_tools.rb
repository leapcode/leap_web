#
# Utilities for use in Gemfile, in order to support
# enabling and disabling gems, and including custom gems
# in the deployment.
#
# Dynamic code in Gemfile is incompatible with
# `bundle install --deployment` because dynamic code might
# produce new Gemfile.lock. For this reason, this app must
# be deployed with `bundle install --path vendor/bundle` instead.
#

require 'yaml'

#
# custom gems are gems placed in config/customization/gems.
# this are added at deploy time by the platform.
# The Gemfile.lock is then rebuilt to take these into account.
#
def custom_gems
  custom_gems = {}
  custom_gem_dir = File.expand_path('../../config/customization/gems', __FILE__)
  Dir["#{custom_gem_dir}/*"].each do |gem_dir|
    custom_gems[File.basename(gem_dir)] = gem_info(gem_dir)
  end
  custom_gems
end

#
# Returns a hash of which gems are enabled. For example:
#
#  {
#    "support" => {
#      :name => 'leap_web_help',
#      :path => 'path/to/engines/support',
#      :env => ['test', 'development']
#    }
#  }
#
# This is built using the 'engines' key from config.yml.
#
# NOTE:
#
# * The name of an engine in config.yml is based on the directory name in Rails.root/engines,
#   but this is not necessarily the name of the gem.
#
def enabled_engines
  engines = {}
  ['test', 'development', 'production'].each do |env|
    if local_config[env] && local_config[env][:engines]
      local_config[env][:engines].each do |engine|
        gem_dir = File.join(File.expand_path("../../engines", __FILE__), engine)
        engines[engine] ||= gem_info(gem_dir)
        engines[engine][:env] << env
      end
    end
  end
  engines
end

#
# local_config can be accessed as an indifferent hash of
# the merger of config/default.yml and config/config.yml
#
def local_config
  @local_config ||= begin
    # a quick and dirty indifferent hash (note: does not affect children):
    empty_hash = {}
    empty_hash.default_proc = proc{|h, k| h.key?(k.to_s) ? h[k.to_s] : nil}
    ["defaults.yml", "config.yml"].inject(empty_hash.dup) {|config, file|
      filepath = File.join(File.expand_path("../../config", __FILE__), file)
      if File.exists?(filepath)
        new_config = YAML.load_file(filepath)
        ['development', 'test','production'].each do |env|
          config[env] ||= empty_hash.dup
          if new_config[env]
            config[env].merge!(new_config[env])
          end
        end
      end
      config
    }
  end
end

#
# return [gem_name, relative_gem_path] for gem at the specific directory
# or nil if not actually a gem directory
#
def gem_info(gem_dir)
  if Dir.exists?(gem_dir)
    gemspec = Dir["#{gem_dir}/*.gemspec"]
    if gemspec.any?
      gem_name = File.basename(gemspec.first).sub(/\.gemspec$/,'')
      {:name => gem_name, :path => gem_dir, :env => []}
    else
      puts "Warning: no gemspec at `#{gem_dir}`"
      {}
    end
  else
    puts "Warning: no gem at `#{gem_dir}`"
    {}
  end
end
