class ServiceLevel

  def initialize(attributes = {})
    @id = attributes[:id] || APP_CONFIG[:default_service_level]
  end

  def self.authenticated_select_options
    APP_CONFIG[:service_levels].map { |id,config_hash| [config_hash[:description], id] if config_hash[:name] != 'anonymous'}.compact
  end

  def id
    @id
  end

  def config_hash
    APP_CONFIG[:service_levels][@id]
  end

  delegate :to_json, to: :config_hash
end
