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
  custom_gem_dir = File.expand_path('../../config/customization/gems', __FILE__)
  Dir["#{custom_gem_dir}/*"].collect{|gem_dir|
    resolve_gem_directory(gem_dir)
  }.compact
end

#
# returns an array of [engine_name, engine_path] from Rails.root/engines/* that are
# enabled. Uses the 'engines' key from config.yml to determine if engine is enabled
#
def enabled_engines(environment)
  if local_config[environment]
    if local_config[environment][:engines]
      local_config[environment][:engines].collect {|engine_dir|
        full_dir_path = File.join(File.expand_path("../../engines", __FILE__), engine_dir)
        resolve_gem_directory(full_dir_path)
      }.compact
    else
      []
    end
  else
    []
  end
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
def resolve_gem_directory(gem_dir)
  if Dir.exists?(gem_dir)
    gemspec = Dir["#{gem_dir}/*.gemspec"]
    if gemspec.any?
      gem_name = File.basename(gemspec.first).sub(/\.gemspec$/,'')
      [gem_name, gem_dir]
    end
  else
    puts "Warning: no gem at `#{gem_dir}`"
    nil
  end
end
