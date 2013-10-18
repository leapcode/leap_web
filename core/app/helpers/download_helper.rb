module DownloadHelper

  def alternative_client_links(os = nil)
    alternative_clients(os).map do |client|
      link_to(client.capitalize, client_download_url(client))
    end
  end

  def alternative_clients(os = nil)
    available_clients - [os]
  end

  def client_download_url(os = nil)
    client_download_domain + client_download_path(os)
  end

  def client_download_path(os)
    download_paths[os.to_s] || download_paths['other'] || ''
  end

  def available_clients
    APP_CONFIG[:available_clients] || []
  end

  def client_download_domain
    APP_CONFIG[:client_download_domain] || ''
  end

  def download_paths
    APP_CONFIG[:download_paths] || {}
  end

end
