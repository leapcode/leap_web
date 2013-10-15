#
# Misc. helpers needed throughout.
#
module CoreHelper

  #
  # insert common buttons (download, login, etc)
  #
  def home_page_buttons
    render 'common/home_page_buttons'
  end

  def available_clients
    CLIENT_AVAILABILITY
  end

  def alternative_client_links(os = nil)
    alternative_clients(os).map do |client|
      link_to(client.capitalize, client_download_url(client))
    end
  end

  def alternative_clients(os = nil)
    CLIENT_AVAILABILITY - [os]
  end

  def client_download_url(os = nil)
    client_download_domain(os) + client_download_path(os)
  end

  def client_download_domain(os)
    "https://downloads.leap.se"
  end

  def client_download_path(os)
    CLIENT_DOWNLOAD_PATHS[os]  || '/client'
  end


  CLIENT_AVAILABILITY = %w/linux32 linux64 mac windows android/
  CLIENT_DOWNLOAD_PATHS = {
    android: '/client/android',
    linux:   '/client/linux',
    linux32: '/client/linux/Bitmask-linux32-latest.tar.bz2',
    linux64: '/client/linux/Bitmask-linux64-latest.tar.bz2',
    osx:     '/client/osx/Bitmask-OSC-latest.dmg',
    windows: '/client/windows'
  }.with_indifferent_access
end
