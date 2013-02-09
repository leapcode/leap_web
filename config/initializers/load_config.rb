def load_config_file(file)
  File.exists?(file) ? YAML.load_file(file)[Rails.env] : {}
end

defaults = load_config_file("#{Rails.root}/config/defaults.yml") || {}
config = load_config_file("#{Rails.root}/config/config.yml") || {}
APP_CONFIG = defaults.merge(config).with_indifferent_access
