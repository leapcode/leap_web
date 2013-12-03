class ServiceLevel

  def initialize(attributes = {})
    @level = attributes[:level] || APP_CONFIG[:default_service_level]
  end

  def level
    @level
  end

  def name
    APP_CONFIG[:service_levels][@level][:name]
  end

  def cert_prefix
    APP_CONFIG[:service_levels][@level][:cert_prefix]
  end

  def description
    APP_CONFIG[:service_levels][@level][:description]
  end

  def cost
    APP_CONFIG[:service_levels][@level][:cost]
  end

  def quota
    APP_CONFIG[:service_levels][@level][:quota]
  end

end
