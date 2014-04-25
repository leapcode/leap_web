class ServiceLevel

  def initialize(attributes = {})
    @id = attributes[:id] || APP_CONFIG[:default_service_level]
  end

  def self.select_options
    APP_CONFIG[:service_levels].map do |id,config_hash|
      [config_hash[:description], id]
    end
  end

  def id
    @id
  end

  delegate :to_json, to: :config_hash

  def cert_prefix
    if limited_cert?
      APP_CONFIG[:limited_cert_prefix]
    elsif APP_CONFIG[:allow_unlimited_certs]
      APP_CONFIG[:unlimited_cert_prefix]
    end
  end

  protected

  def limited_cert?
    APP_CONFIG[:allow_limited_certs] &&
      (!APP_CONFIG[:allow_unlimited_certs] || config_hash[:eip_rate_limit])
  end

  def config_hash
    @config_hash || APP_CONFIG[:service_levels][@id].with_indifferent_access
  end

end
