class AnonymousServiceLevel

  delegate :to_json, to: :config_hash

  def cert_prefix
    if APP_CONFIG[:allow_limited_certs]
      APP_CONFIG[:limited_cert_prefix]
    else
      APP_CONFIG[:unlimited_cert_prefix]
    end
  end

  def description
    if APP_CONFIG[:allow_anonymous_certs]
      "anonymous access to the VPN"
    else
      "please login to access our services"
    end
  end

  protected

  def config_hash
    { name: "anonymous",
      description: description,
      cost: 0,
      eip_rate_limit: APP_CONFIG[:allow_limited_certs]
    }
  end

end
